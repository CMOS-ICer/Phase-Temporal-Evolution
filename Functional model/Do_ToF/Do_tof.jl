module DoTofMWorksFixedV7

using SysplorerAPI
using Printf

export DoTofConfig, run_do_tof_full_model, main

Base.@kwdef struct DoTofConfig
    fa::Float64 = 60e6
    fb::Float64 = 60_001_000.0
    c::Float64 = 3e8
    A::Float64 = 6e6
    offset::Float64 = 4.5e6
    v_start::Float64 = 1.0
    v_stop::Float64 = 10.0
    v_step::Float64 = 1.0
    sim_time::Float64 = 8e-3
    points_per_cycle::Int = 100
    sample_limit::Union{Nothing,Int} = nothing
    model_relpath::String = joinpath("model", "Do_tof.mo")
    safe_model_relpath::String = joinpath("model", "Do_tof.mo")
    runtime_model_name::String = "Do_tof"
    result_csv::String = "Do_tof_full_model_results.csv"
end

const DO_TOF_HEADERS = [
    "TheoryVelocity_m_per_s",
    "DopplerShift_Hz",
    "M_Output",
    "CalculatedVelocity_m_per_s",
    "Heterodyne_He",
    "Homodyne_Ho",
    "VelocityError_m_per_s",
    "Runtime_s",
    "SamplesPerExposure",
]

function theory_velocities(cfg::DoTofConfig)
    return collect(cfg.v_start:cfg.v_step:cfg.v_stop)
end

function effective_sample_count(cfg::DoTofConfig)
    full_count = round(Int, cfg.fa * cfg.sim_time * cfg.points_per_cycle)
    return cfg.sample_limit === nothing ? full_count : min(full_count, cfg.sample_limit)
end

function waveform_for_velocity(v::Float64, cfg::DoTofConfig)
    n = effective_sample_count(cfg)
    n < 2 && error("sample count must be at least 2")

    data = Matrix{Float64}(undef, n, 2)
    dt = cfg.sim_time / (n - 1)
    fd = 2 * v * cfg.fa / cfg.c

    @inbounds for i in 1:n
        t = (i - 1) * dt
        data[i, 1] = t
        data[i, 2] = cfg.A * sin(2.0 * pi * (cfg.fa + fd) * t) + cfg.offset
    end
    return data, dt, fd
end

real_literal(x::Real) = @sprintf("%.17g", Float64(x))

function patch_model_for_batch_run!(project_dir::String, cfg::DoTofConfig)
    src_path = abspath(joinpath(project_dir, cfg.model_relpath))
    isfile(src_path) || error("Cannot find MWorks model file: $(src_path)")

    text = read(src_path, String)
    text = replace(text, r"^model\s+Do_tof\b"m => "model $(cfg.runtime_model_name)")
    text = replace(text, r"^end\s+Do_tof;"m => "end $(cfg.runtime_model_name);")
    text = replace(text, r"parameter\s+Real\s+fa\s*=\s*[^;]+;" => "parameter Real fa = $(real_literal(cfg.fa));")
    text = replace(text, r"parameter\s+Real\s+fb\s*=\s*[^;]+;" => "parameter Real fb = $(real_literal(cfg.fb));")
    text = replace(text,
        r"ToWorkspace(\d*)?\s+'([^']+)'\(var_name=\"(simout|Heterodyne|Homodyne)\",extract=1,max_data_point=1\)" =>
        s"ToWorkspace\1 '\2'(var_name=\"\3\",extract=0,max_data_point=1)")
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

    # Fail early if the runtime model still contains the bad output-extraction settings.
    for bad in ("var_name=\"simout\",extract=1",
                "var_name=\"Heterodyne\",extract=1",
                "var_name=\"Homodyne\",extract=1")
        occursin(bad, text) && error("Patch failed; runtime model still contains: $(bad)")
    end
    text = replace(text, "Product Divide(inputs=\"*/\"" => "Product Divide(inputs=\"2\"")

    safe_path = abspath(joinpath(project_dir, cfg.safe_model_relpath))
    mkpath(dirname(safe_path))
    write(safe_path, text)
    @printf("runtime-safe model: %s\n", relpath(safe_path, project_dir))
    return safe_path
end

function two_point_series(value::Real, stop_time::Float64)
    return [0.0 Float64(value); stop_time Float64(value)]
end

function prepare_workspace_variables!(cfg::DoTofConfig; wave_data::Union{Nothing,Matrix{Float64}} = nothing)
    Main.fa = cfg.fa
    Main.fb = cfg.fb
    Main.Reflected_Light_Wave_Data = wave_data === nothing ? two_point_series(cfg.offset, cfg.sim_time) : wave_data
    Main.simout = two_point_series(0.0, cfg.sim_time)
    Main.Heterodyne = two_point_series(0.0, cfg.sim_time)
    Main.Homodyne = two_point_series(0.0, cfg.sim_time)
    Main.out = nothing
    return nothing
end

function connect_and_open!(model_path::String, cfg::DoTofConfig)
    prepare_workspace_variables!(cfg)
    SysplorerAPI.ConnectSysplorer()
    opened = OpenModelFile(model_path)
    opened == true || error("Cannot open $(model_path). Start Sysplorer from Syslab, then rerun this script.")
    return nothing
end

function run_imported_model!(model_name::String, cfg::DoTofConfig, dt::Float64)
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

@inline function pulse50(t::Float64, f::Float64, phase::Float64)
    T = 1.0 / f
    x = mod(t - phase, T)
    return x < 0.5 * T ? 1.0 : 0.0
end

function model_equivalent_integrals(wave_data::Matrix{Float64}, dt::Float64, cfg::DoTofConfig)
    homo0 = 0.0
    homo180 = 0.0
    hetero0 = 0.0
    hetero180 = 0.0
    nstep = size(wave_data, 1) - 1

    @inbounds for i in 1:nstep
        t = Float64(wave_data[i, 1])
        x = Float64(wave_data[i, 2])
        homo0    += x * pulse50(t, cfg.fa, 0.0)
        homo180  += x * pulse50(t, cfg.fa, 0.5 / cfg.fa)
        hetero0  += x * pulse50(t, cfg.fb, 0.0)
        hetero180 += x * pulse50(t, cfg.fb, 0.5 / cfg.fb)
    end

    return (Heterodyne = (hetero0 - hetero180) * dt,
            Homodyne = (homo0 - homo180) * dt)
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

    error("ToWorkspace variable `$(name)` was not created. Check the block variable name and target workspace.")
end

function simulate_velocity!(v::Float64, cfg::DoTofConfig, model_name::String)
    wave_data, dt, fd = waveform_for_velocity(v, cfg)
    prepare_workspace_variables!(cfg; wave_data = wave_data)

    elapsed = @elapsed run_imported_model!(model_name, cfg, dt)

    heterodyne = workspace_value_or_nothing(:Heterodyne)
    homodyne = workspace_value_or_nothing(:Homodyne)

    if heterodyne === nothing || homodyne === nothing
        ints = model_equivalent_integrals(wave_data, dt, cfg)
        heterodyne = ints.Heterodyne
        homodyne = ints.Homodyne
        @printf("MWorks ToWorkspace output was not visible to Julia; using equivalent fixed-step Euler integrals.\n")
    end

    m_output = abs(heterodyne) < eps(Float64) ? NaN : homodyne / heterodyne

    v_calc = (isnan(m_output) || abs(m_output - 1.0) < eps(Float64)) ?
             NaN :
             ((cfg.fa - cfg.fb) * cfg.c) / (2 * (m_output - 1.0) * cfg.fa)

    return (
        TheoryVelocity_m_per_s = v,
        DopplerShift_Hz = fd,
        M_Output = m_output,
        CalculatedVelocity_m_per_s = v_calc,
        Heterodyne_He = heterodyne,
        Homodyne_Ho = homodyne,
        VelocityError_m_per_s = v_calc - v,
        Runtime_s = elapsed,
        SamplesPerExposure = size(wave_data, 1),
    )
end

function write_csv(path::String, rows)
    open(path, "w") do io
        println(io, join(DO_TOF_HEADERS, ","))
        for row in rows
            println(io, join((getfield(row, Symbol(h)) for h in DO_TOF_HEADERS), ","))
        end
    end
end

function run_do_tof_full_model(cfg::DoTofConfig = DoTofConfig())
    project_dir = @__DIR__
    model_name = cfg.runtime_model_name
    sample_count = effective_sample_count(cfg)

    @printf("Doppler ToF full imported model run: %d samples per exposure, %.6g s exposure\n", sample_count, cfg.sim_time)

    model_path = patch_model_for_batch_run!(project_dir, cfg)
    connect_and_open!(model_path, cfg)

    rows = NamedTuple[]
    for v in theory_velocities(cfg)
        row = simulate_velocity!(v, cfg, model_name)
        push!(rows, row)
        @printf("velocity %.3f m/s, M %.9g, calculated %.6f m/s\n", v, row.M_Output, row.CalculatedVelocity_m_per_s)
    end

    csv_path = joinpath(project_dir, cfg.result_csv)
    write_csv(csv_path, rows)
    println("result: ", relpath(csv_path, project_dir))
    return rows
end

function main()
    cfg = DoTofConfig()
    return run_do_tof_full_model(cfg)
end

end 

if abspath(PROGRAM_FILE) == @__FILE__
    DoTofMWorksFixedV7.main()
end

