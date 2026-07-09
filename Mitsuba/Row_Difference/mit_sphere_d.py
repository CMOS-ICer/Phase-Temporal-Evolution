import mitsuba as mi
import drjit as dr
import numpy as np
import matplotlib.pyplot as plt
import os
import shutil
from math import tan, radians, sqrt
from matplotlib import colors as mcolors
ALLOWED_OUTPUT_FILENAMES = ['depth_combined_combined_w512x512_oddT8.0ms_evenT80.0ms_v1-2.00_v23.00.npy', 'depth_combined_combined_w512x512_oddT8.0ms_evenT80.0ms_v1-2.00_v23.00.png', 'rgb_avg_even_w512x512_f100MHz_T80.0ms_NT10_spp64_v1-2.00_v23.00.png']

def output_allowed_path(path):
    return os.path.basename(str(path)) in ALLOWED_OUTPUT_FILENAMES
VARIANT = 'cuda_ad_rgb'
OUT_DIR = 'result_sphere_d'
IMG_W, IMG_H = (512, 512)
SPP = 100
MOD_FREQ = 100000000.0
EXPOSURE = 0.005
NT = 100
OBJ1_INIT_Z = 0.8
OBJ2_INIT_Z = 0.8
SPEED_OBJ1 = 3.0
SPEED_OBJ2 = 0
CUBE_EDGE = 0.15
SPHERE_DIAM = CUBE_EDGE / 1.0
CUBE_ROT_DEG1 = 0
CUBE_ROT_DEG2 = 0
CAM_ORIGIN = [0.0, 0.06, 0.0]
CAM_TARGET = [0.0, 0.06, 2.0]
CAM_UP = [0.0, 0.15, 0.0]
CAM_FOV = 60.0
LUMA_WEIGHTS = np.array([0.2126, 0.7152, 0.0722], dtype=np.float32)
C = 300000000.0
GAP_T = 0.025
EXPOSURE_ODD = 0.008
EXPOSURE_EVEN = 0.08
EXPOSURE = EXPOSURE_ODD
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

def save_npy_png(array: np.ndarray, basepath: str, cmap: str='viridis', vmin: float=None, vmax: float=None, norm=None, title: str=None, cbar_label: str=None):
    if not (output_allowed_path(basepath + '.npy') or output_allowed_path(basepath + '.png')):
        return
    if output_allowed_path(basepath + '.npy'):
        np.save(basepath + '.npy', array)
    plt.figure(figsize=(6, 6))
    if norm is not None:
        im = plt.imshow(array, cmap=cmap, norm=norm)
    else:
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

def save_rgb_npy_png(rgb: np.ndarray, basepath: str, title: str=None):
    if not (output_allowed_path(basepath + '.npy') or output_allowed_path(basepath + '.png')):
        return
    if output_allowed_path(basepath + '.npy'):
        np.save(basepath + '.npy', rgb.astype(np.float32))
    img = rgb.copy()
    mask = np.isfinite(img)
    if not np.any(mask):
        vis = np.zeros((img.shape[0], img.shape[1], 3), dtype=np.float32)
    else:
        finite_vals = img[mask].reshape(-1, 3)
        vmin = np.percentile(finite_vals, 1.0, axis=0)
        vmax = np.percentile(finite_vals, 99.0, axis=0)
        diff = vmax - vmin
        diff[diff == 0] = 1.0
        vis = (img - vmin.reshape(1, 1, 3)) / diff.reshape(1, 1, 3)
        vis = np.clip(vis, 0.0, 1.0)
        vis[~np.isfinite(vis)] = 0.0
    if output_allowed_path(basepath + '.png'):
        plt.imsave(basepath + '.png', vis)

def make_scene(cube_z: float, sphere_z: float) -> mi.Scene:
    sphere_radius = SPHERE_DIAM / 2.0
    hy1 = float(CUBE_EDGE / 0.7)
    hy2 = float(CUBE_EDGE / 2.0)
    ground_y = 0.0
    teapot_half_h = float(CUBE_EDGE / 2.0)
    teapot_center_y = float(ground_y + teapot_half_h)
    wall_z = float(1.3)
    script_dir = os.path.dirname(os.path.abspath(__file__)) if '__file__' in globals() else os.getcwd()
    candidate_local = os.path.join(script_dir, 'teapot.ply')
    candidate_tutorial = os.path.join(script_dir, '..', 'scenes', 'meshes', 'teapot.ply')
    teapot_path = None
    if os.path.exists(candidate_local):
        teapot_path = os.path.abspath(candidate_local)
    elif os.path.exists(candidate_tutorial):
        teapot_path = os.path.abspath(candidate_tutorial)
    scene_dict = {'type': 'scene', 'integrator': {'type': 'path'}, 'sensor': {'type': 'perspective', 'to_world': mi.ScalarTransform4f.look_at(origin=CAM_ORIGIN, target=CAM_TARGET, up=CAM_UP), 'fov': CAM_FOV, 'film': {'type': 'hdrfilm', 'width': IMG_W, 'height': IMG_H, 'rfilter': {'type': 'tent'}, 'pixel_format': 'rgb'}, 'sampler': {'type': 'multijitter', 'sample_count': SPP}}, 'env_emitter': {'type': 'constant', 'radiance': {'type': 'rgb', 'value': [0.2, 0.2, 0.2]}}, 'wall': {'type': 'rectangle', 'to_world': mi.ScalarTransform4f.translate([0.0, 1.2, wall_z]) @ mi.ScalarTransform4f.rotate([0, 1, 0], 180.0) @ mi.ScalarTransform4f.scale([5.0, 3.0, 1.0]), 'bsdf': {'type': 'roughplastic', 'alpha': 0.65, 'diffuse_reflectance': {'type': 'rgb', 'value': [0.65, 0.64, 0.62]}, 'specular_reflectance': {'type': 'rgb', 'value': [0.01, 0.01, 0.01]}}}, 'ground': {'type': 'rectangle', 'to_world': mi.ScalarTransform4f.translate([0.0, -0.15, 0.0]) @ mi.ScalarTransform4f.rotate([1, 0, 0], -90.0) @ mi.ScalarTransform4f.scale([5.0, 2, 5.0]), 'bsdf': {'type': 'roughplastic', 'alpha': 0.22, 'diffuse_reflectance': {'type': 'rgb', 'value': [0.36, 0.28, 0.22]}, 'specular_reflectance': {'type': 'rgb', 'value': [0.04, 0.04, 0.04]}}}, 'sphere': {'type': 'sphere', 'to_world': mi.ScalarTransform4f.translate([0, 0, cube_z]) @ mi.ScalarTransform4f.scale(0.15), 'bsdf': {'type': 'roughplastic', 'alpha': 1.0, 'diffuse_reflectance': {'type': 'rgb', 'value': [0.95, 0.72, 0.55]}, 'specular_reflectance': {'type': 'rgb', 'value': [0.01, 0.01, 0.01]}}}}
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

def run_once(start_time: float, run_name: str):
    T = float(EXPOSURE)
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
    hy1 = float(CUBE_EDGE / 0.7)
    hz1 = float(CUBE_EDGE / 1.0)
    hx2 = float(CUBE_EDGE / 2.0)
    hy2 = float(CUBE_EDGE / 2.0)
    hz2 = float(CUBE_EDGE / 1.0)
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
    rgb_accum = None
    for k, t in enumerate(ts):
        cur_t = start_time + float(t)
        cube_front = float(OBJ1_INIT_Z - SPEED_OBJ1 * cur_t)
        sphere_front = float(OBJ2_INIT_Z - SPEED_OBJ2 * cur_t)
        cube_Cx = -0.12
        cube_Cy = float(hy1)
        sphere_Cx = 0.12
        sphere_Cy = float(hy2)
        RHS1 = cube_front + support1 + dot_f_o
        RHS2 = sphere_front + support2 + dot_f_o
        if abs(forward[2]) < 1e-06:
            cube_z = float(cube_front + CUBE_EDGE / 2.0)
            sphere_z = float(sphere_front + CUBE_EDGE / 2.0)
        else:
            cube_z = float((RHS1 - forward[0] * cube_Cx - forward[1] * cube_Cy) / forward[2])
            sphere_z = float((RHS2 - forward[0] * sphere_Cx - forward[1] * sphere_Cy) / forward[2])
        scene = make_scene(cube_z=cube_z, sphere_z=sphere_z)
        img = mi.render(scene, spp=SPP)
        rgb = np.asarray(img, dtype=np.float32)
        if rgb.ndim == 2:
            rgb = np.stack([rgb, rgb, rgb], axis=-1)
        if rgb.ndim == 3 and rgb.shape[2] >= 3:
            gray = (rgb[..., :3] @ LUMA_WEIGHTS).astype(np.float32)
        else:
            gray = np.squeeze(rgb).astype(np.float32)
        gray = np.nan_to_num(gray, nan=0.0, posinf=0.0, neginf=0.0)
        if rgb_accum is None:
            H, W = gray.shape
            rgb_accum = np.zeros((H, W, 3), dtype=np.float64)
        rgb_step = rgb[..., :3].astype(np.float64)
        rgb_accum += rgb_step * float(dt)
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
            try:
                pos_integrator = mi.load_dict({'type': 'aov', 'aovs': 'position:position'})
                pos_render = mi.render(scene, spp=max(8, SPP // 4), integrator=pos_integrator)
                pos_img = np.asarray(pos_render, dtype=np.float32)
                if pos_img.ndim == 3 and pos_img.shape[2] >= 3:
                    pos_xyz = pos_img[..., :3]
                    cam_origin_arr = np.array(CAM_ORIGIN, dtype=np.float32).reshape((1, 1, 3))
                    dists = np.sqrt(np.sum((pos_xyz - cam_origin_arr) ** 2, axis=2)).astype(np.float32)
                    depth_img[nan_mask] = dists[nan_mask]
            except Exception as e:
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
    if np.any(depth_map < -1e-09):
        depth_map = depth_map.copy()
        depth_map[np.isfinite(depth_map)] = np.clip(depth_map[np.isfinite(depth_map)], 0.0, None)
    if rgb_accum is None:
        H, W = (IMG_H, IMG_W)
        avg_rgb = np.zeros((H, W, 3), dtype=np.float32)
    else:
        avg_rgb = (rgb_accum / float(T)).astype(np.float32)
    tag = f'{run_name}_w{IMG_W}x{IMG_H}_f{int(MOD_FREQ / 1000000.0)}MHz_T{EXPOSURE * 1000.0:.1f}ms_NT{NT}_spp{SPP}_v1{SPEED_OBJ1:.2f}_v2{SPEED_OBJ2:.2f}'
    return {'I0': I0.astype(np.float32), 'I90': I90.astype(np.float32), 'I180': I180.astype(np.float32), 'I270': I270.astype(np.float32), 'diff0_180': diff0_180, 'diff90_270': diff90_270, 'phase_wrapped': phase_wrapped, 'amplitude': amplitude, 'depth_map': depth_map, 'tag': tag, 'T': T, 'rgb': avg_rgb}

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
    valid = np.isfinite(depth)
    if np.any(valid):
        try:
            p_lo, p_hi = np.nanpercentile(depth, [2.0, 98.0])
        except Exception:
            p_lo, p_hi = (float(np.nanmin(depth)), float(np.nanmax(depth)))
        if not np.isfinite(p_lo) or not np.isfinite(p_hi) or p_hi <= p_lo:
            p_lo, p_hi = (float(np.nanmin(depth)), float(np.nanmax(depth)))
        span = p_hi - p_lo
        if span <= 1e-06:
            p_lo = p_lo - 0.5 * max(1e-06, abs(p_lo))
            p_hi = p_hi + 0.5 * max(1e-06, abs(p_hi))
        else:
            pad = 0.1 * span
            p_lo = p_lo - pad
            p_hi = p_hi + pad
        gamma = 0.7
        depth_norm = mcolors.PowerNorm(gamma=gamma, vmin=p_lo, vmax=p_hi)
        save_npy_png(depth, os.path.join(OUT_DIR, f'depth_map_{tag}'), cmap='turbo', norm=depth_norm, title=f'Estimated Depth (m) - {tag}', cbar_label='Depth (m)')
    else:
        save_npy_png(depth, os.path.join(OUT_DIR, f'depth_map_{tag}'), cmap='viridis', vmin=None, vmax=None, title=f'Estimated Depth (m) - {tag}', cbar_label='Depth (m)')
    if 'rgb' in run and run['rgb'] is not None:
        if tag.startswith('even_'):
            save_rgb_npy_png(run['rgb'], os.path.join(OUT_DIR, 'rgb_avg_even_w512x512_f100MHz_T80.0ms_NT10_spp64_v1-2.00_v23.00'), title=f'RGB Average - {tag}')

def main():
    ensure_dir(OUT_DIR)
    clear_dir_contents(OUT_DIR)
    prev_exposure = globals().get('EXPOSURE', EXPOSURE)
    globals()['EXPOSURE'] = EXPOSURE_ODD
    run_odd = run_once(start_time=0.0, run_name='odd')
    save_run_outputs(run_odd)
    globals()['EXPOSURE'] = EXPOSURE_EVEN
    run_even = run_once(start_time=0.0, run_name='even')
    save_run_outputs(run_even)
    globals()['EXPOSURE'] = prev_exposure
    depth_odd = run_odd['depth_map']
    depth_even = run_even['depth_map']
    rgb_odd = run_odd['rgb']
    rgb_even = run_even['rgb']
    H, W = depth_odd.shape
    depth_comb = np.full((H, W), np.nan, dtype=np.float32)
    rgb_comb = np.full((H, W, 3), np.nan, dtype=np.float32)
    odd_idx = np.arange(0, H, 2)
    even_idx = np.arange(1, H, 2)
    depth_comb[odd_idx, :] = depth_odd[odd_idx, :]
    rgb_comb[odd_idx, :, :] = rgb_odd[odd_idx, :, :]
    depth_comb[even_idx, :] = depth_even[even_idx, :]
    rgb_comb[even_idx, :, :] = rgb_even[even_idx, :, :]
    combined_tag = f'combined_w{IMG_W}x{IMG_H}_oddT{EXPOSURE_ODD * 1000.0:.1f}ms_evenT{EXPOSURE_EVEN * 1000.0:.1f}ms_v{SPEED_OBJ1:.2f}'
    save_npy_png(depth_comb, os.path.join(OUT_DIR, 'depth_combined_combined_w512x512_oddT8.0ms_evenT80.0ms_v1-2.00_v23.00'), cmap='turbo', title=f'Combined Depth (odd/even rows) - {combined_tag}', cbar_label='Depth (m)')
    save_rgb_npy_png(rgb_comb, os.path.join(OUT_DIR, f'rgb_combined_{combined_tag}'), title=f'Combined RGB (odd/even rows) - {combined_tag}')
    denom = (EXPOSURE_EVEN - EXPOSURE_ODD) / 2.0
    if abs(denom) < 1e-12:
        raise ValueError('EXPOSURE_EVEN approx EXPOSURE_ODD ')
    vmap = np.full((H - 1, W), np.nan, dtype=np.float32)
    for i in range(0, H - 1):
        row_i_is_odd = (i + 1) % 2 == 1
        if row_i_is_odd:
            odd_row_idx = i
            even_row_idx = i + 1
            odd_depth_row = depth_odd[odd_row_idx, :]
            even_depth_row = depth_even[even_row_idx, :]
        else:
            even_row_idx = i
            odd_row_idx = i + 1
            even_depth_row = depth_even[even_row_idx, :]
            odd_depth_row = depth_odd[odd_row_idx, :]
        numerator = even_depth_row - odd_depth_row
        with np.errstate(invalid='ignore', divide='ignore'):
            v_row = numerator / denom
        valid_mask = np.isfinite(numerator) & np.isfinite(denom)
        if np.any(valid_mask):
            vmap[i, valid_mask] = v_row[valid_mask]
    save_npy_png(vmap, os.path.join(OUT_DIR, f'velocity_map_rowpair_{combined_tag}'), cmap='seismic', vmin=None, vmax=None, title=f'Velocity Map per adjacent-row pair (H-1 x W) - {combined_tag}', cbar_label='Velocity (m/s)')
if __name__ == '__main__':
    main()
