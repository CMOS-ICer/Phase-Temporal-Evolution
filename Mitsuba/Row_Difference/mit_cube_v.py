import mitsuba as mi
import drjit as dr
import numpy as np
import matplotlib.pyplot as plt
import os
import shutil
from math import tan, radians, sqrt
VARIANT = 'cuda_ad_rgb'
OUT_DIR = 'result_cube_v'
IMG_W, IMG_H = (512, 512)
SPP = 100
MOD_FREQ = 100000000.0
EXPOSURE_ODD = 0.008
EXPOSURE_EVEN = 0.08
EXPOSURE = EXPOSURE_ODD
NT = 100
OBJ1_INIT_Z = 0.9
OBJ2_INIT_Z = 0
SPEED_OBJ1 = 3.875
SPEED_OBJ2 = 0
CUBE_EDGE = 0.15
SPHERE_DIAM = CUBE_EDGE / 1.0
CUBE_ROT_DEG1 = 0
CUBE_ROT_DEG2 = 0
CAM_ORIGIN = [0.0, 0.075, 0.0]
CAM_TARGET = [0.0, 0.075, 2.0]
CAM_UP = [0.0, 1.0, 0.0]
CAM_FOV = 80.0
LUMA_WEIGHTS = np.array([0.2126, 0.7152, 0.0722], dtype=np.float32)
C = 300000000.0
GAP_T = 0.025
mi.set_variant(VARIANT)

def ensure_dir(path: str):
    if not os.path.exists(path):
        os.makedirs(path, exist_ok=True)

def clear_dir_contents(path: str):
    if os.path.exists(path):
        for name in os.listdir(path):
            p = os.path.join(path, name)
            try:
                if os.path.isfile(p) or os.path.islink(p):
                    os.unlink(p)
                elif os.path.isdir(p):
                    shutil.rmtree(p)
            except Exception as e:
                pass
import matplotlib.cm as cm
from matplotlib.colors import Normalize
import matplotlib.image as mimage
ALLOWED_OUTPUT_FILENAMES = ['depth_combined_rows_odd8ms_even80ms.npy', 'velocity_rows_diff_formula.png', 'velocity_rows_diff_formula_colorbar.png']

def output_allowed_path(path):
    return os.path.basename(str(path)) in ALLOWED_OUTPUT_FILENAMES

def save_npy_png(array: np.ndarray, basepath: str, cmap: str='viridis', vmin: float=None, vmax: float=None, title: str=None, cbar_label: str=None):
    if not (output_allowed_path(basepath + '.npy') or output_allowed_path(basepath + '.png')):
        return
    if output_allowed_path(basepath + '.npy'):
        np.save(basepath + '.npy', array)
    plt.figure(figsize=(6, 6))
    im = plt.imshow(array, cmap=cmap, vmin=vmin, vmax=vmax)
    plt.axis('off')
    if title is not None:
        plt.title(title)
    if cbar_label is not None:
        cbar = plt.colorbar(im, fraction=0.046, pad=0.04)
        cbar.set_label(cbar_label)
    plt.tight_layout()
    if output_allowed_path(basepath + '.png'):
        plt.savefig(basepath + '.png', dpi=160, bbox_inches='tight')
    plt.close()

def save_image_no_cbar_exact_pixels(array: np.ndarray, basepath: str, vmin: float=None, vmax: float=None, cmap_name: str='viridis'):
    if not output_allowed_path(basepath + '.png'):
        return
    img = np.asarray(array)
    if img.ndim != 2:
        img = np.squeeze(img)
    H, W = img.shape
    assert W == IMG_W and H == IMG_H, f'期待尺寸 {IMG_W}x{IMG_H}，但得到 {W}x{H}'
    cmap = cm.get_cmap(cmap_name)
    finite_mask = np.isfinite(img)
    if vmin is None or vmax is None:
        if np.any(finite_mask):
            auto_vmin = float(np.nanmin(img)) if vmin is None else vmin
            auto_vmax = float(np.nanmax(img)) if vmax is None else vmax
            if auto_vmin == auto_vmax:
                auto_vmin -= 1e-06
                auto_vmax += 1e-06
            use_vmin, use_vmax = (auto_vmin, auto_vmax)
        else:
            use_vmin, use_vmax = (0.0, 1.0)
    else:
        use_vmin, use_vmax = (float(vmin), float(vmax))
        if use_vmin == use_vmax:
            use_vmin -= 1e-06
            use_vmax += 1e-06
    norm = Normalize(vmin=use_vmin, vmax=use_vmax, clip=True)
    mapped = cm.get_cmap(cmap_name)(norm(np.where(finite_mask, img, use_vmin)))
    mapped[~finite_mask, 0:3] = 1.0
    mapped[~finite_mask, 3] = 1.0
    mapped_u8 = (np.clip(mapped, 0.0, 1.0) * 255).astype(np.uint8)
    if output_allowed_path(basepath + '.png'):
        mimage.imsave(basepath + '.png', mapped_u8, format='png')

def save_colorbar_vertical_png(array: np.ndarray, basepath: str, cmap_name: str='viridis', vmin: float=None, vmax: float=None, cbar_label: str='Depth (m)', dpi: int=300, height_inches: float=6.0, width_inches: float=1.0, ticks: list=None):
    if not output_allowed_path(basepath + '_colorbar.png'):
        return
    finite_mask = np.isfinite(array)
    if vmin is None or vmax is None:
        if np.any(finite_mask):
            auto_vmin = float(np.nanmin(array)) if vmin is None else vmin
            auto_vmax = float(np.nanmax(array)) if vmax is None else vmax
        else:
            auto_vmin, auto_vmax = (0.0, 1.0)
    else:
        auto_vmin, auto_vmax = (float(vmin), float(vmax))
        if auto_vmin == auto_vmax:
            auto_vmin -= 1e-06
            auto_vmax += 1e-06
    fig = plt.figure(figsize=(width_inches, height_inches), dpi=dpi)
    ax = fig.add_axes([0.35, 0.05, 0.3, 0.9])
    cmap = cm.get_cmap(cmap_name)
    norm = Normalize(vmin=auto_vmin, vmax=auto_vmax)
    sm = cm.ScalarMappable(cmap=cmap, norm=norm)
    sm.set_array([])
    cbar = fig.colorbar(sm, cax=ax, orientation='vertical')
    if ticks is not None:
        cbar.set_ticks(ticks)
    cbar.set_label(cbar_label)
    out_path = basepath + '_colorbar.png'
    if output_allowed_path(out_path):
        fig.savefig(out_path, dpi=dpi, bbox_inches='tight')
    plt.close(fig)
    print(f'Saved colorbar: {out_path}')

def make_scene(cube_z: float, sphere_z: float) -> mi.Scene:
    sphere_radius = SPHERE_DIAM / 2.0
    hy1 = float(CUBE_EDGE / 0.7)
    hy2 = float(CUBE_EDGE / 2.0)
    ground_y = 0.0
    cube_center_y = float(ground_y + hy1)
    sphere_center_y = float(ground_y + hy2)
    wall_z = float(1.3)
    scene_dict = {'type': 'scene', 'integrator': {'type': 'path'}, 'sensor': {'type': 'perspective', 'to_world': mi.ScalarTransform4f.look_at(origin=CAM_ORIGIN, target=CAM_TARGET, up=CAM_UP), 'fov': CAM_FOV, 'film': {'type': 'hdrfilm', 'width': IMG_W, 'height': IMG_H, 'rfilter': {'type': 'tent'}, 'pixel_format': 'rgb'}, 'sampler': {'type': 'multijitter', 'sample_count': SPP}}, 'env_emitter': {'type': 'constant', 'radiance': {'type': 'rgb', 'value': [0.1, 0.1, 0.1]}}, 'cube': {'type': 'cube', 'to_world': mi.ScalarTransform4f.translate([0, 0, cube_z]) @ mi.ScalarTransform4f.rotate([0, 1, 0], CUBE_ROT_DEG1) @ mi.ScalarTransform4f.scale([CUBE_EDGE / 2.0, CUBE_EDGE / 0.7, CUBE_EDGE / 2.0]), 'bsdf': {'type': 'diffuse', 'reflectance': {'type': 'rgb', 'value': [0.95, 0.3, 0.3]}}}}
    return mi.load_dict(scene_dict)

def render_gray(scene: mi.Scene, spp: int=SPP) -> np.ndarray:
    img = mi.render(scene, spp=spp)
    rgb = np.asarray(img, dtype=np.float32)
    if rgb.ndim == 3 and rgb.shape[2] >= 3:
        gray = (rgb[..., :3] @ LUMA_WEIGHTS).astype(np.float32)
    else:
        gray = np.squeeze(rgb).astype(np.float32)
    gray = np.nan_to_num(gray, nan=0.0, posinf=0.0, neginf=0.0)
    return gray

def world_point_to_pixel(x: float, y: float, z: float, img_w: int=IMG_W, img_h: int=IMG_H, fov_deg: float=CAM_FOV):
    origin = np.array(CAM_ORIGIN, dtype=np.float64)
    target = np.array(CAM_TARGET, dtype=np.float64)
    up = np.array(CAM_UP, dtype=np.float64)
    forward = target - origin
    fnorm = np.linalg.norm(forward)
    if fnorm == 0:
        return None
    forward = forward / fnorm
    right = np.cross(forward, up)
    rnorm = np.linalg.norm(right)
    if rnorm == 0:
        return None
    right = right / rnorm
    up_cam = np.cross(right, forward)
    pt = np.array([x, y, z], dtype=np.float64)
    vec = pt - origin
    z_cam = np.dot(forward, vec)
    if z_cam <= 1e-09:
        return None
    x_cam = np.dot(right, vec)
    y_cam = np.dot(up_cam, vec)
    fov_rad = radians(fov_deg)
    fy = img_h / 2.0 / tan(fov_rad / 2.0)
    fx = fy
    cx = img_w / 2.0
    cy = img_h / 2.0
    u = fx * (x_cam / z_cam) + cx
    v = fy * (-y_cam / z_cam) + cy
    if u < 0 or u > img_w - 1 or v < 0 or (v > img_h - 1):
        return None
    return (int(round(u)), int(round(v)))

def run_once(start_time: float, run_name: str, exposure: float=None):
    T = float(EXPOSURE) if exposure is None else float(exposure)
    f = float(MOD_FREQ)
    ts = (np.arange(NT) + 0.5) * T / NT
    dt = T / NT
    ref_phases = np.array([0.0, 0.5 * np.pi, np.pi, 1.5 * np.pi], dtype=np.float64)
    acc = [None, None, None, None]
    origin = np.array(CAM_ORIGIN, dtype=np.float64)
    target = np.array(CAM_TARGET, dtype=np.float64)
    forward_vec = target - origin
    forward_norm = np.linalg.norm(forward_vec)
    if forward_norm == 0.0:
        forward = np.array([0.0, 0.0, 1.0], dtype=np.float64)
    else:
        forward = forward_vec / forward_norm
    fov_rad = radians(CAM_FOV)
    fy_pix = IMG_H / 2.0 / tan(fov_rad / 2.0)
    fx_pix = fy_pix
    cx = IMG_W / 2.0
    cy = IMG_H / 2.0
    u_coord = (np.arange(IMG_W).astype(np.float32) - cx) / fx_pix
    v_coord = (np.arange(IMG_H).astype(np.float32) - cy) / fy_pix
    uu, vv = np.meshgrid(u_coord, v_coord)
    ray_cos_theta = 1.0 / np.sqrt(uu * uu + vv * vv + 1.0)
    hx1 = float(CUBE_EDGE / 2.0)
    hy1 = float(CUBE_EDGE / 2.0)
    hz1 = float(CUBE_EDGE / 2.0)
    hx2 = float(CUBE_EDGE / 2.0)
    hy2 = float(CUBE_EDGE / 2.0)
    hz2 = float(CUBE_EDGE / 2.0)
    fx_w, fy_w, fz_w = (float(forward[0]), float(forward[1]), float(forward[2]))
    theta1 = radians(float(CUBE_ROT_DEG1))
    theta2 = radians(float(CUBE_ROT_DEG2))
    cos1 = np.cos(theta1)
    sin1 = np.sin(theta1)
    f_dot_rx1 = fx_w * cos1 + fy_w * 0.0 + fz_w * sin1
    f_dot_ry1 = fx_w * 0.0 + fy_w * 1.0 + fz_w * 0.0
    f_dot_rz1 = fx_w * -sin1 + fy_w * 0.0 + fz_w * cos1
    support1 = abs(f_dot_rx1) * hx1 + abs(f_dot_ry1) * hy1 + abs(f_dot_rz1) * hz1
    cos2 = np.cos(theta2)
    sin2 = np.sin(theta2)
    f_dot_rx2 = fx_w * cos2 + fy_w * 0.0 + fz_w * sin2
    f_dot_ry2 = fx_w * 0.0 + fy_w * 1.0 + fz_w * 0.0
    f_dot_rz2 = fx_w * -sin2 + fy_w * 0.0 + fz_w * cos2
    support2 = abs(f_dot_rx2) * hx2 + abs(f_dot_ry2) * hy2 + abs(f_dot_rz2) * hz2
    dot_f_o = float(np.dot(forward, origin))
    for k, t in enumerate(ts):
        cur_t = start_time + float(t)
        teapot_front = float(OBJ1_INIT_Z - SPEED_OBJ1 * cur_t)
        spare_front = float(OBJ2_INIT_Z - SPEED_OBJ2 * cur_t)
        teapot_Cx = 0.0
        teapot_Cy = float(hy1)
        spare_Cx = 0.12
        spare_Cy = float(hy2)
        RHS1 = teapot_front + support1 + dot_f_o
        RHS2 = spare_front + support2 + dot_f_o
        if abs(forward[2]) < 1e-06:
            teapot_center_z = float(teapot_front + CUBE_EDGE / 2.0)
            spare_center_z = float(spare_front + CUBE_EDGE / 2.0)
        else:
            teapot_center_z = float((RHS1 - forward[0] * teapot_Cx - forward[1] * teapot_Cy) / forward[2])
            spare_center_z = float((RHS2 - forward[0] * spare_Cx - forward[1] * spare_Cy) / forward[2])
        scene = make_scene(cube_z=teapot_center_z, sphere_z=spare_center_z)
        gray = render_gray(scene, spp=SPP)
        depth_img = None
        try:
            integrator = mi.load_dict({'type': 'aov', 'aovs': 'depth:depth'})
            depth_render = mi.render(scene, spp=SPP, integrator=integrator)
            depth_img = np.asarray(depth_render, dtype=np.float32)
        except Exception as e:
            raise
        if depth_img.ndim == 3 and depth_img.shape[2] >= 1:
            depth_img = np.squeeze(depth_img[..., 0])
        depth_img = depth_img.astype(np.float32)
        depth_img[~np.isfinite(depth_img)] = np.nan
        depth_img[depth_img <= 0.0] = np.nan
        depth_img[depth_img > 1000.0] = np.nan
        nan_mask = ~np.isfinite(depth_img)
        if np.any(nan_mask):
            pass
        perp_depth = depth_img * ray_cos_theta
        phi_scene = (4.0 * np.pi * f * perp_depth / C).astype(np.float64)
        for i in range(4):
            cos_term = np.cos(phi_scene - ref_phases[i])
            cos_term[np.isnan(cos_term)] = 0.0
            contrib = gray.astype(np.float64) * dt * cos_term
            if acc[i] is None:
                acc[i] = contrib.copy()
            else:
                acc[i] += contrib
        if (k + 1) % max(1, NT // 10) == 0 or k + 1 == NT:
            pass
    I0, I90, I180, I270 = [a.astype(np.float64) for a in acc]
    diff0_180 = (I0 - I180).astype(np.float32)
    diff90_270 = (I90 - I270).astype(np.float32)
    raw_phase = np.arctan2(I90 - I270, I0 - I180).astype(np.float64)
    phase_wrapped = np.mod(raw_phase, 2.0 * np.pi).astype(np.float32)
    amplitude = np.sqrt((I0 - I180) ** 2 + (I90 - I270) ** 2).astype(np.float32)
    amp_thr = 1e-20
    invalid_mask = amplitude < amp_thr
    depth_map = (C * phase_wrapped / (4.0 * np.pi * f)).astype(np.float32)
    fallback_mask = invalid_mask & np.isfinite(perp_depth)
    if np.any(fallback_mask):
        depth_map = depth_map.copy()
        depth_map[fallback_mask] = perp_depth[fallback_mask].astype(np.float32)
    depth_map[invalid_mask & ~np.isfinite(perp_depth)] = np.nan
    depth_map[nan_mask] = np.nan
    if np.any(depth_map < -1e-09):
        depth_map = depth_map.copy()
        depth_map[np.isfinite(depth_map)] = np.clip(depth_map[np.isfinite(depth_map)], 0.0, None)
    tag = f'{run_name}_w{IMG_W}x{IMG_H}_f{int(MOD_FREQ / 1000000.0)}MHz_T{T * 1000.0:.1f}ms_NT{NT}_spp{SPP}_v1{SPEED_OBJ1:.2f}_v2{SPEED_OBJ2:.2f}'
    return {'I0': I0.astype(np.float32), 'I90': I90.astype(np.float32), 'I180': I180.astype(np.float32), 'I270': I270.astype(np.float32), 'diff0_180': diff0_180, 'diff90_270': diff90_270, 'phase_wrapped': phase_wrapped, 'amplitude': amplitude, 'depth_map': depth_map, 'tag': tag, 'T': T}

def sample_roi_mean(img: np.ndarray, uv, r: int):
    if uv is None:
        return None
    u, v = uv
    H, W = img.shape
    u0 = max(0, u - r)
    u1 = min(W - 1, u + r)
    v0 = max(0, v - r)
    v1 = min(H - 1, v + r)
    patch = img[v0:v1 + 1, u0:u1 + 1]
    if patch.size == 0:
        return None
    patch_valid = patch[np.isfinite(patch)]
    if patch_valid.size == 0:
        return None
    return float(np.nanmean(patch_valid))

def euclidean_dist(pt, cam_origin=CAM_ORIGIN):
    dx = pt[0] - cam_origin[0]
    dy = pt[1] - cam_origin[1]
    dz = pt[2] - cam_origin[2]
    return sqrt(dx * dx + dy * dy + dz * dz)

def save_run_outputs(run: dict):
    tag = run['tag']
    ensure_dir(OUT_DIR)
    save_npy_png(run['I0'], os.path.join(OUT_DIR, f'I0_{tag}'), cmap='magma', title=f'I0 (0°) - {tag}')
    save_npy_png(run['I90'], os.path.join(OUT_DIR, f'I90_{tag}'), cmap='magma', title=f'I90 (90°) - {tag}')
    save_npy_png(run['I180'], os.path.join(OUT_DIR, f'I180_{tag}'), cmap='magma', title=f'I180 (180°) - {tag}')
    save_npy_png(run['I270'], os.path.join(OUT_DIR, f'I270_{tag}'), cmap='magma', title=f'I270 (270°) - {tag}')
    save_npy_png(run['diff0_180'], os.path.join(OUT_DIR, f'diff0_180_{tag}'), cmap='seismic', title=f'I0 - I180 - {tag}', cbar_label='Intensity diff')
    save_npy_png(run['diff90_270'], os.path.join(OUT_DIR, f'diff90_270_{tag}'), cmap='seismic', title=f'I90 - I270 - {tag}', cbar_label='Intensity diff')
    save_npy_png(run['phase_wrapped'], os.path.join(OUT_DIR, f'phase_wrapped_{tag}'), cmap='twilight', title=f'Phase (0..2π) - {tag}', cbar_label='Phase (rad)')
    save_npy_png(run['amplitude'], os.path.join(OUT_DIR, f'amplitude_{tag}'), cmap='magma', title=f'Amplitude (SNR) - {tag}', cbar_label='Amplitude')
    depth = run['depth_map']
    depth_base = os.path.join(OUT_DIR, f'depth_map_{tag}')
    if output_allowed_path(depth_base + '.npy'):
        np.save(depth_base + '.npy', depth)
    depth_for_png = np.copy(depth)
    finite_mask = np.isfinite(depth_for_png)
    if np.any(finite_mask):
        depth_for_png[finite_mask] = np.clip(depth_for_png[finite_mask], 0.1, 0.9)
    save_image_no_cbar_exact_pixels(depth_for_png, depth_base, vmin=0.1, vmax=0.9, cmap_name='viridis')
    save_colorbar_vertical_png(depth, depth_base, cmap_name='viridis', vmin=0.1, vmax=0.9, cbar_label='Depth (normalized 0..1)', dpi=300, height_inches=6.0, width_inches=1.2)
    print(f'Saved depth images and colorbar for {tag}')

def main():
    ensure_dir(OUT_DIR)
    clear_dir_contents(OUT_DIR)
    run_odd = run_once(start_time=0.0, run_name='odd_rows', exposure=EXPOSURE_ODD)
    save_run_outputs(run_odd)
    run_even = run_once(start_time=0.0, run_name='even_rows', exposure=EXPOSURE_EVEN)
    save_run_outputs(run_even)
    depth_odd = run_odd['depth_map']
    depth_even = run_even['depth_map']
    assert depth_odd.shape == (IMG_H, IMG_W) and depth_even.shape == (IMG_H, IMG_W), ''
    combined_depth = np.full((IMG_H, IMG_W), np.nan, dtype=np.float32)
    combined_depth[0:IMG_H:2, :] = depth_odd[0:IMG_H:2, :]
    combined_depth[1:IMG_H:2, :] = depth_even[1:IMG_H:2, :]
    combined_base = os.path.join(OUT_DIR, 'depth_combined_rows_odd8ms_even80ms')
    if output_allowed_path(combined_base + '.npy'):
        np.save(combined_base + '.npy', combined_depth)
    combined_for_png = np.copy(combined_depth)
    finite_mask_cd = np.isfinite(combined_for_png)
    if np.any(finite_mask_cd):
        combined_for_png[finite_mask_cd] = np.clip(combined_for_png[finite_mask_cd], 0.1, 0.9)
    save_image_no_cbar_exact_pixels(combined_for_png, combined_base, vmin=0.1, vmax=0.9, cmap_name='viridis')
    save_colorbar_vertical_png(combined_depth, combined_base, cmap_name='viridis', vmin=0.1, vmax=0.9, cbar_label='Depth (normalized 0..1)', dpi=300, height_inches=6.0, width_inches=1.2)
    print(f'Saved combined depth map: {combined_base}.npy/.png and colorbar')
    denom = (float(EXPOSURE_EVEN) - float(EXPOSURE_ODD)) / 2.0
    if abs(denom) < 1e-12:
        vmap_full = np.full((IMG_H, IMG_W), np.nan, dtype=np.float32)
    else:
        vmap_full = np.full((IMG_H, IMG_W), np.nan, dtype=np.float32)
        for r in range(IMG_H):
            if r % 2 == 0:
                idx_even = r
                if r + 1 < IMG_H:
                    idx_odd = r + 1
                elif r - 1 >= 0:
                    idx_odd = r - 1
                else:
                    idx_odd = None
            else:
                idx_odd = r
                if r + 1 < IMG_H:
                    idx_even = r + 1
                elif r - 1 >= 0:
                    idx_even = r - 1
                else:
                    idx_even = None
            if idx_even is None or idx_odd is None:
                vmap_full[r, :] = np.full((IMG_W,), np.nan, dtype=np.float32)
                continue
            row_even = depth_even[idx_even, :]
            row_odd = depth_odd[idx_odd, :]
            valid_mask = np.isfinite(row_even) & np.isfinite(row_odd)
            if not np.any(valid_mask):
                vmap_full[r, :] = np.full((IMG_W,), np.nan, dtype=np.float32)
            else:
                vrow = np.full((IMG_W,), np.nan, dtype=np.float32)
                vrow[valid_mask] = ((row_even[valid_mask] - row_odd[valid_mask]) / denom).astype(np.float32)
                vmap_full[r, :] = vrow
    vel_base = os.path.join(OUT_DIR, 'velocity_rows_diff_formula')
    if output_allowed_path(vel_base + '.npy'):
        np.save(vel_base + '.npy', vmap_full)
    vmap_for_png = np.copy(vmap_full)
    finite_mask_v = np.isfinite(vmap_for_png)
    if np.any(finite_mask_v):
        vmap_for_png[finite_mask_v] = np.clip(vmap_for_png[finite_mask_v], -10.0, 10.0)
    save_image_no_cbar_exact_pixels(vmap_for_png, vel_base, vmin=-10.0, vmax=10.0, cmap_name='seismic')
    save_colorbar_vertical_png(vmap_full, vel_base, cmap_name='seismic', vmin=-10.0, vmax=10.0, cbar_label='Velocity (m/s)', dpi=300, height_inches=6.0, width_inches=1.2)
if __name__ == '__main__':
    main()
