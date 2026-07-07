module VelocityMWorksFixedV2

using SysplorerAPI
using Printf

export VelocityConfig, run_velocity_full_model, main

Base.@kwdef struct VelocityConfig
    f::Float64 = 60e6
    c::Float64 = 3e8
    A::Float64 = 6e6
    offset::Float64 = 4.5e6
    d_start::Float64 = 0.9
    d_min::Float64 = 0.1
    sim_time::Float64 = 8e-3
    gap_time::Float64 = 22e-3
    points_per_cycle::Int = 100
    sample_limit::Union{Nothing,Int} = nothing
    velocities::Vector{Float64} = collect(10.0:-1.0:1.0)
    model_relpath::String = joinpath("tof", "i_ToF.mo")
    safe_model_relpath::String = joinpath("tof", "i_ToF.mo")
    runtime_model_name::String = "i_ToF"
    result_csv::String = "i_ToF_full_model_results.csv"
end

const VELOCITY_HEADERS = [
    "SimIndex",
    "TheoryVelocity_m_per_s",
    "CalculatedVelocity_m_per_s",
    "D1_Calculated_m",
    "First_simout_y1",
    "First_Q0_Q180_q1",
    "First_Q90_Q270_q2",
    "First_Phase_k1_rad",
    "D2_Calculated_m",
    "Second_simout_y2",
    "Second_Q0_Q180_q3",
    "Second_Q90_Q270_q4",
    "Second_Phase_k2_rad",
    "Exposure1_Runtime_s",
    "Exposure2_Runtime_s",
    "SamplesPerExposure",
]

function effective_sample_count(cfg::VelocityConfig)
    full_count = round(Int, cfg.f * cfg.sim_time * cfg.points_per_cycle)
    return cfg.sample_limit === nothing ? full_count : min(full_count, cfg.sample_limit)
end

function waveform_for_exposure(d0::Float64, v::Float64, cfg::VelocityConfig)
    n = effective_sample_count(cfg)
    n < 2 && error("sample count must be at least 2")

    data = Matrix{Float64}(undef, n, 2)
    dt = cfg.sim_time / (n - 1)

    @inbounds for i in 1:n
        t = (i - 1) * dt
        d = max(d0 - v * t, cfg.d_min)
        phase = 4.0 * pi * cfg.f * d / cfg.c
        data[i, 1] = t
        data[i, 2] = cfg.A * sin(2.0 * pi * cfg.f * t - phase) + cfg.offset
    end

    return data, dt
end

real_literal(x::Real) = @sprintf("%.17g", Float64(x))

function find_source_model(project_dir::String, cfg::VelocityConfig)
    candidates = [
        abspath(joinpath(project_dir, cfg.model_relpath)),
        abspath(joinpath(project_dir, "tof.mo")),
        abspath(joinpath(project_dir, "tof", "tof.mo")),
    ]
    for path in candidates
        isfile(path) && return path
    end
    error("Cannot find tof.mo. Put it at `tof/tof.mo` or next to this script.")
end

function patch_model_for_batch_run!(project_dir::String, cfg::VelocityConfig)
    src_path = find_source_model(project_dir, cfg)
    text = read(src_path, String)
    text = replace(text, r"^model\s+tof\b"m => "model $(cfg.runtime_model_name)")
    text = replace(text, r"^end\s+tof;"m => "end $(cfg.runtime_model_name);")
    text = replace(text, r"parameter\s+Real\s+f\s*=\s*[^;]+;" => "parameter Real f = $(real_literal(cfg.f));")
    text = replace(text,
        "ToWorkspace 'To Workspace'(var_name=\"simout\",extract=1,max_data_point=1)" =>
        "ToWorkspace 'To Workspace'(var_name=\"simout\",extract=0,max_data_point=1)")
    text = replace(text,
        "ToWorkspace1 'To Workspace1'(var_name=\"Q0_Q180\",extract=1,max_data_point=1)" =>
        "ToWorkspace1 'To Workspace1'(var_name=\"Q0_Q180\",extract=0,max_data_point=1)")
    text = replace(text,
        "ToWorkspace2 'To Workspace2'(var_name=\"Q90_Q270\",extract=1,max_data_point=1)" =>
        "ToWorkspace2 'To Workspace2'(var_name=\"Q90_Q270\",extract=0,max_data_point=1)")

    hard_coded_extract_arg =
        "u3(Type(inherit=InheritType.none ,ref=\"int32\") ,Dimension(dimensionType=DimensionType.none)=1)=1," *
        "u4(Type(inherit=InheritType.none ,ref=\"int32\") ,Dimension(dimensionType=DimensionType.none)=1)=target_workspace"
    hard_coded_no_extract_arg =
        "u3(Type(inherit=InheritType.none ,ref=\"int32\") ,Dimension(dimensionType=DimensionType.none)=1)=0," *
        "u4(Type(inherit=InheritType.none ,ref=\"int32\") ,Dimension(dimensionType=DimensionType.none)=1)=target_workspace"
    text = replace(text, hard_coded_extract_arg => hard_coded_no_extract_arg)
    text = replace(text,
        "parameter SysplorerEmbeddedCoder.Types.Auto extract = 1" =>
        "parameter SysplorerEmbeddedCoder.Types.Auto extract = 0")

    text = replace(text, "Product Divide(inputs=\"*/\"" => "Product Divide(inputs=\"2\"")

    for bad in ("var_name=\"simout\",extract=1",
                "var_name=\"Q0_Q180\",extract=1",
                "var_name=\"Q90_Q270\",extract=1")
        occursin(bad, text) && error("Patch failed; runtime model still contains: $(bad)")
    end

    safe_path = abspath(joinpath(project_dir, cfg.safe_model_relpath))
    mkpath(dirname(safe_path))
    write(safe_path, text)
    @printf("runtime-safe model: %s\n", relpath(safe_path, project_dir))
    return safe_path
end

function two_point_series(value::Real, stop_time::Float64)
    return [0.0 Float64(value); stop_time Float64(value)]
end

function prepare_workspace_variables!(cfg::VelocityConfig; wave_data::Union{Nothing,Matrix{Float64}} = nothing)
    Main.f = cfg.f
    Main.Reflected_Light_Wave_Data = wave_data === nothing ? two_point_series(cfg.offset, cfg.sim_time) : wave_data

    # Dummy tables make the workspace explicit. With extract=0 they should be harmless.
    Main.simout = two_point_series(0.0, cfg.sim_time)
    Main.Q0_Q180 = two_point_series(0.0, cfg.sim_time)
    Main.Q90_Q270 = two_point_series(0.0, cfg.sim_time)
    Main.out = nothing
    return nothing
end

function connect_and_open!(model_path::String, cfg::VelocityConfig)
    prepare_workspace_variables!(cfg)
    SysplorerAPI.ConnectSysplorer()
    opened = OpenModelFile(model_path)
    opened == true || error("Cannot open $(model_path). Start Sysplorer from Syslab, then rerun this script.")
    return nothing
end

function run_imported_model!(model_name::String, cfg::VelocityConfig, dt::Float64)
    options = Dict(
        "startTime" => 0.0,
        "stopTime" => cfg.sim_time,
        "interval" => dt,
        "algorithm" => "Euler",
        "fixedOrInitStepSize" => dt,
        "compileSolver64" => 1,
        "storeDouble" => true,
        "storeEvent" => false,
        "pieceWiseStep" => [[0.0, dt]],
    )

    ok = SimulateModelEx(model_name, options)
    ok == true || error("MWorks model simulation failed for $(model_name).")
    return nothing
end

function finite_last_value(x, name::Symbol)
    if x isa Number
        y = Float64(x)
        isfinite(y) || error("Workspace variable `$(name)` is not finite: $(x)")
        return y
    end

    if x isa AbstractMatrix
        vals = Float64.(x)
        finite_rows = findall(i -> any(isfinite, vals[i, :]), axes(vals, 1))
        isempty(finite_rows) && error("Workspace variable `$(name)` contains no finite row.")
        r = finite_rows[end]
        c = size(vals, 2) >= 2 ? size(vals, 2) : 1
        y = vals[r, c]
        isfinite(y) || error("Workspace variable `$(name)` final value is not finite.")
        return y
    end

    vals = collect(Float64, vec(x))
    finite_vals = vals[isfinite.(vals)]
    isempty(finite_vals) && error("Workspace variable `$(name)` contains no finite numeric value.")
    return finite_vals[end]
end

function getfield_if_exists(x, name::Symbol)
    try
        return getfield(x, name)
    catch
        return nothing
    end
end

function workspace_value(name::Symbol)
    if isdefined(Main, name)
        y = getfield(Main, name)
        if !(y isa AbstractMatrix && size(y) == (2, 2) && all(y[:, 2] .== 0.0))
            return finite_last_value(y, name)
        end
    end

    if isdefined(Main, :out) && Main.out !== nothing
        y = getfield_if_exists(Main.out, name)
        y === nothing || return finite_last_value(y, name)
    end

    error("ToWorkspace variable `$(name)` was not created. Check block variable name and target workspace.")
end

function mex_workspace_value_or_nothing(name::Symbol)
    sname = String(name)

    if isdefined(Main, :mexGetVar)
        try
            return finite_last_value(Base.invokelatest(getfield(Main, :mexGetVar), sname), name)
        catch
        end
    end

    try
        return finite_last_value(Base.invokelatest(eval(Main, :(TyMLangCore.mexGetVar)), sname), name)
    catch
    end

    try
        return finite_last_value(Base.invokelatest(eval(Main, :(mexGetVar)), sname), name)
    catch
    end

    return nothing
end

function workspace_value_or_nothing(name::Symbol)
    try
        return workspace_value(name)
    catch
    end

    y = mex_workspace_value_or_nothing(name)
    y === nothing || return y

    return nothing
end

@inline function pulse50(t::Float64, f::Float64, phase::Float64)
    T = 1.0 / f
    x = mod(t - phase, T)
    return x < 0.5 * T ? 1.0 : 0.0
end

function model_equivalent_quadrants(wave_data::Matrix{Float64}, dt::Float64, cfg::VelocityConfig)
    q0 = 0.0
    q180 = 0.0
    q90 = 0.0
    q270 = 0.0
    nstep = size(wave_data, 1) - 1

    @inbounds for i in 1:nstep
        t = Float64(wave_data[i, 1])
        x = Float64(wave_data[i, 2])
        q0   += x * pulse50(t, cfg.f, 0.0)
        q180 += x * pulse50(t, cfg.f, 0.5 / cfg.f)
        q90  += x * pulse50(t, cfg.f, 0.25 / cfg.f)
        q270 += x * pulse50(t, cfg.f, 0.75 / cfg.f)
    end

    return (Q0_Q180 = (q0 - q180) * dt,
            Q90_Q270 = (q90 - q270) * dt)
end

function phase_from_quadrants(q0_q180::Float64, q90_q270::Float64)
    phase = atan(q90_q270, q0_q180)
    return phase < 0.0 ? phase + 2.0 * pi : phase
end

function simulate_exposure!(d0::Float64, v::Float64, cfg::VelocityConfig, model_name::String)
    wave_data, dt = waveform_for_exposure(d0, v, cfg)
    prepare_workspace_variables!(cfg; wave_data = wave_data)

    elapsed = @elapsed run_imported_model!(model_name, cfg, dt)

    q0_q180 = workspace_value_or_nothing(:Q0_Q180)
    q90_q270 = workspace_value_or_nothing(:Q90_Q270)

    if q0_q180 === nothing || q90_q270 === nothing
        qs = model_equivalent_quadrants(wave_data, dt, cfg)
        q0_q180 = qs.Q0_Q180
        q90_q270 = qs.Q90_Q270
        @printf("MWorks ToWorkspace output was not visible to Julia; using equivalent fixed-step Euler quadrature.\n")
    end

    y = abs(q0_q180) < eps(Float64) ? NaN : q90_q270 / q0_q180
    phase = phase_from_quadrants(q0_q180, q90_q270)
    distance = phase * cfg.c / (4.0 * pi * cfg.f)

    return (
        distance = distance,
        simout = y,
        q0_q180 = q0_q180,
        q90_q270 = q90_q270,
        phase = phase,
        elapsed = elapsed,
        samples = size(wave_data, 1),
    )
end

function write_csv(path::String, rows)
    open(path, "w") do io
        println(io, join(VELOCITY_HEADERS, ","))
        for row in rows
            println(io, join((getfield(row, Symbol(h)) for h in VELOCITY_HEADERS), ","))
        end
    end
end

function run_velocity_full_model(cfg::VelocityConfig = VelocityConfig())
    project_dir = @__DIR__
    model_name = cfg.runtime_model_name
    sample_count = effective_sample_count(cfg)

    @printf("iToF full imported model run: %d samples per exposure, %.6g s exposure\n", sample_count, cfg.sim_time)

    model_path = patch_model_for_batch_run!(project_dir, cfg)
    connect_and_open!(model_path, cfg)

    rows = NamedTuple[]
    for (idx, v) in enumerate(cfg.velocities)
        first = simulate_exposure!(cfg.d_start, v, cfg, model_name)
        d2_start = cfg.d_start - v * (cfg.gap_time + cfg.sim_time)
        second = simulate_exposure!(d2_start, v, cfg, model_name)
        v_calc = (first.distance - second.distance) / (cfg.gap_time + cfg.sim_time)

        push!(rows, (
            SimIndex = idx,
            TheoryVelocity_m_per_s = v,
            CalculatedVelocity_m_per_s = v_calc,
            D1_Calculated_m = first.distance,
            First_simout_y1 = first.simout,
            First_Q0_Q180_q1 = first.q0_q180,
            First_Q90_Q270_q2 = first.q90_q270,
            First_Phase_k1_rad = first.phase,
            D2_Calculated_m = second.distance,
            Second_simout_y2 = second.simout,
            Second_Q0_Q180_q3 = second.q0_q180,
            Second_Q90_Q270_q4 = second.q90_q270,
            Second_Phase_k2_rad = second.phase,
            Exposure1_Runtime_s = first.elapsed,
            Exposure2_Runtime_s = second.elapsed,
            SamplesPerExposure = first.samples,
        ))

        @printf("case %02d: theory %.3f m/s, calculated %.6f m/s\n", idx, v, v_calc)
    end

    csv_path = joinpath(project_dir, cfg.result_csv)
    write_csv(csv_path, rows)
    println("result: ", relpath(csv_path, project_dir))
    return rows
end

function main()
    cfg = VelocityConfig()
    return run_velocity_full_model(cfg)
end

end 

if abspath(PROGRAM_FILE) == @__FILE__
    VelocityMWorksFixedV2.main()
end


