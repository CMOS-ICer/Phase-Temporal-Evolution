import mitsuba as mi                                                       
import drjit as dr                                                           
import numpy as np                                     
import os                                          
import shutil                                       
from math import tan, radians, sqrt                            

                                                                  
VARIANT = "cuda_ad_rgb"                                                 
OUT_DIR = "result_cube"                                         
IMG_W, IMG_H = 512, 512                              
SPP = 100                                                       
MOD_FREQ = 100e6                                        
EXPOSURE = 8e-3                                            
NT = 100                                                    
OBJ1_INIT_Z = 0.9                                                        
OBJ2_INIT_Z = 0                                                  
SPEED_OBJ1 = 6                                                  
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
C = 3.0e8                                         
GAP_T = 22e-3                                                                                                                                                             
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

                                                                          
def make_scene(cube_z: float, sphere_z: float) -> mi.Scene:                                 
    sphere_radius = SPHERE_DIAM / 2.0                                        
                                            
    hy1 = float(CUBE_EDGE / 0.7)                                      
    hy2 = float(CUBE_EDGE / 2.0)                                      
    ground_y = 0.0                                                               
                                                    
    cube_center_y = float(ground_y + hy1)                               
    sphere_center_y = float(ground_y + hy2)                             
    wall_z = float(1.3)                                                            
                           
    scene_dict = {                                                   
        "type": "scene",                                      
        "integrator": {"type": "path"},                                
        "sensor": {                                               
            "type": "perspective",                          
            "to_world": mi.ScalarTransform4f.look_at(                    
                origin=CAM_ORIGIN,                          
                target=CAM_TARGET,                          
                up=CAM_UP                                  
            ),                                                       
            "fov": CAM_FOV,                                   
            "film": {                                        
                "type": "hdrfilm",                                
                "width": IMG_W,                             
                "height": IMG_H,                            
                "rfilter": {"type": "tent"},                         
                "pixel_format": "rgb"                            
            },                                                   
            "sampler": {                                     
                "type": "multijitter",                           
                "sample_count": SPP                                   
            }                                                    
        },                                                      

        "env_emitter": {                                             
            "type": "constant",                                     
            "radiance": {"type": "rgb", "value": [0.1, 0.1, 0.1]}                
        },                                                           

                                                 
        "cube": {                                                 
            "type": "cube",                                     
            "to_world": (                                                   
                mi.ScalarTransform4f.translate([0, cube_center_y, cube_z]) @                      
                mi.ScalarTransform4f.rotate([0, 1, 0], CUBE_ROT_DEG1) @             
                mi.ScalarTransform4f.scale([CUBE_EDGE/2.0, CUBE_EDGE/0.7, CUBE_EDGE/2.0])                 
            ),                                                         
            "bsdf": {                                                     
                "type": "diffuse",
                "reflectance": {"type": "rgb", "value": [0.95, 0.3, 0.3]}      
            }                                                      
        },                                                       


    }                                                               

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
                                                                     
def world_point_to_pixel(x: float, y: float, z: float,
                         img_w: int=IMG_W, img_h: int=IMG_H,
                         fov_deg: float=CAM_FOV):                              
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
    if z_cam <= 1e-9:                                               
        return None
    x_cam = np.dot(right, vec)                                    
    y_cam = np.dot(up_cam, vec)                                   
    fov_rad = radians(fov_deg)                                 
    fy = (img_h / 2.0) / tan(fov_rad / 2.0)                      
    fx = fy                                                          
    cx = img_w / 2.0                                           
    cy = img_h / 2.0                                           
    u = fx * (x_cam / z_cam) + cx                             
    v = fy * (-y_cam / z_cam) + cy                                     
    if u < 0 or u > img_w - 1 or v < 0 or v > img_h - 1:                 
        return None
    return int(round(u)), int(round(v))                               

                                                                             
def run_once(start_time: float, run_name: str):                                         
    T = float(EXPOSURE)                                         
    f = float(MOD_FREQ)                                          
    dt = T / NT
    ts = (np.arange(NT) + 0.5) * T / NT
    ref_phases = np.array([0.0, 0.5*np.pi, np.pi, 1.5*np.pi], dtype=np.float64)          
    acc = [None, None, None, None]                                               
    pass

    origin = np.array(CAM_ORIGIN, dtype=np.float64)                 
    target = np.array(CAM_TARGET, dtype=np.float64)                 
    forward_vec = target - origin                                    
    forward_norm = np.linalg.norm(forward_vec)                
    if forward_norm == 0.0:                                          
        forward = np.array([0.0, 0.0, 1.0], dtype=np.float64)           
    else:
        forward = forward_vec / forward_norm                          
    fov_rad = radians(CAM_FOV)                                
    fy_pix = (IMG_H / 2.0) / tan(fov_rad / 2.0)                    
    fx_pix = fy_pix                                            
    cx = IMG_W / 2.0                                             
    cy = IMG_H / 2.0                                             
    u_coord = (np.arange(IMG_W).astype(np.float32) - cx) / fx_pix           
    v_coord = (np.arange(IMG_H).astype(np.float32) - cy) / fy_pix           
    uu, vv = np.meshgrid(u_coord, v_coord)                      
    ray_cos_theta = 1.0 / np.sqrt(uu*uu + vv*vv + 1.0)               

                                                                  
    hx1 = float(CUBE_EDGE / 2.0)                                     
    hy1 = float(CUBE_EDGE / 0.7)                                     
    hz1 = float(CUBE_EDGE / 2.0)                                     
    hx2 = float(CUBE_EDGE / 2.0)                                     
    hy2 = float(CUBE_EDGE / 2.0)                                     
    hz2 = float(CUBE_EDGE / 1.0)                                     

                                            
    fx_w, fy_w, fz_w = float(forward[0]), float(forward[1]), float(forward[2])                     
    theta1 = radians(float(CUBE_ROT_DEG1))                          
    theta2 = radians(float(CUBE_ROT_DEG2))                          
    cos1 = np.cos(theta1)                                           
    sin1 = np.sin(theta1)                                           
    f_dot_rx1 = fx_w * cos1 + fy_w * 0.0 + fz_w * sin1                          
    f_dot_ry1 = fx_w * 0.0 + fy_w * 1.0 + fz_w * 0.0                            
    f_dot_rz1 = fx_w * (-sin1) + fy_w * 0.0 + fz_w * cos1                        
    support1 = abs(f_dot_rx1) * hx1 + abs(f_dot_ry1) * hy1 + abs(f_dot_rz1) * hz1              
    cos2 = np.cos(theta2)                                           
    sin2 = np.sin(theta2)                                           
    f_dot_rx2 = fx_w * cos2 + fy_w * 0.0 + fz_w * sin2                          
    f_dot_ry2 = fx_w * 0.0 + fy_w * 1.0 + fz_w * 0.0                            
    f_dot_rz2 = fx_w * (-sin2) + fy_w * 0.0 + fz_w * cos2                        
    support2 = abs(f_dot_rx2) * hx2 + abs(f_dot_ry2) * hy2 + abs(f_dot_rz2) * hz2              

                               
    dot_f_o = float(np.dot(forward, origin))                                       

                             
    for k, t in enumerate(ts):                                         
        cur_t = start_time + float(t)                                   
        cube_front = float((OBJ1_INIT_Z + 0.01) - SPEED_OBJ1 * cur_t)                     
        sphere_front = float(OBJ2_INIT_Z - SPEED_OBJ2 * cur_t)                   

                                                                    
        cube_Cx = 0.0                                                                 
        cube_Cy = float(hy1)                                                      
        sphere_Cx = 0.12                                                                
        sphere_Cy = float(hy2)                                                   

        RHS1 = cube_front + support1 + dot_f_o                             
        RHS2 = sphere_front + support2 + dot_f_o                           

        if abs(forward[2]) < 1e-6:                                           
            cube_z = float(cube_front + (CUBE_EDGE / 2.0))                  
            sphere_z = float(sphere_front + (CUBE_EDGE / 2.0))         
        else:
            cube_z = float((RHS1 - forward[0]*cube_Cx - forward[1]*cube_Cy) / forward[2])                   
            sphere_z = float((RHS2 - forward[0]*sphere_Cx - forward[1]*sphere_Cy) / forward[2])                 

                                                   
        scene = make_scene(cube_z=cube_z, sphere_z=sphere_z)                           
        gray = render_gray(scene, spp=SPP)                                    

                                                
        depth_img = None                                                      
        try:
            integrator = mi.load_dict({"type": "aov", "aovs": "depth:depth"})                 
            depth_render = mi.render(scene, spp=SPP, integrator=integrator)                 
            depth_img = np.asarray(depth_render, dtype=np.float32)                                   
        except Exception as e:
            pass
            raise                                                       

        if depth_img.ndim == 3 and depth_img.shape[2] >= 1:                     
            depth_img = np.squeeze(depth_img[..., 0])                      

        depth_img = depth_img.astype(np.float32)                             
        depth_img[~np.isfinite(depth_img)] = np.nan                     
        depth_img[depth_img <= 0.0] = np.nan                            
        depth_img[depth_img > 1e3] = np.nan                                   

                                                                               
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

        if (k + 1) % max(1, NT // 10) == 0 or (k + 1) == NT:                        
            pass

                                       
    I0, I90, I180, I270 = [a.astype(np.float64) for a in acc]                   

    diff0_180 = (I0 - I180).astype(np.float32)                                             
    diff90_270 = (I90 - I270).astype(np.float32)                                            

    raw_phase = np.arctan2((I90 - I270), (I0 - I180)).astype(np.float64)              
    phase_wrapped = np.mod(raw_phase, 2.0 * np.pi).astype(np.float32)                 

    amplitude = np.sqrt((I0 - I180)**2 + (I90 - I270)**2).astype(np.float32)               
    amp_thr = 1e-20                                                                       
    invalid_mask = amplitude < amp_thr                                                  

    depth_map = ((C * phase_wrapped) / (4.0 * np.pi * f)).astype(np.float32)             
    fallback_mask = invalid_mask & np.isfinite(perp_depth)                                        
    if np.any(fallback_mask):                                                             
        depth_map = depth_map.copy()                                                   
        depth_map[fallback_mask] = perp_depth[fallback_mask].astype(np.float32)             
                                                                  
    depth_map[invalid_mask & ~np.isfinite(perp_depth)] = np.nan                                 

                                                                                
                                                                  
    depth_map[nan_mask] = np.nan                                                              

    if np.any(depth_map < -1e-9):                                                             
        depth_map = depth_map.copy()                                                    
        depth_map[np.isfinite(depth_map)] = np.clip(depth_map[np.isfinite(depth_map)], 0.0, None)            

    tag = f"{run_name}_w{IMG_W}x{IMG_H}_f{int(MOD_FREQ/1e6)}MHz_T{EXPOSURE*1e3:.1f}ms_NT{NT}_spp{SPP}_v1{SPEED_OBJ1:.2f}_v2{SPEED_OBJ2:.2f}"          

    return {
        "I0": I0.astype(np.float32), "I90": I90.astype(np.float32), "I180": I180.astype(np.float32), "I270": I270.astype(np.float32),
        "diff0_180": diff0_180, "diff90_270": diff90_270, "phase_wrapped": phase_wrapped,
        "amplitude": amplitude, "depth_map": depth_map, "tag": tag, "T": T
    }                        

                                                                       
def sample_roi_mean(img: np.ndarray, uv, r: int):                                     
    if uv is None:                                                    
        return None
    u, v = uv                                                
    H, W = img.shape                                         
    u0 = max(0, u - r); u1 = min(W - 1, u + r)               
    v0 = max(0, v - r); v1 = min(H - 1, v + r)               
    patch = img[v0:v1+1, u0:u1+1]                            
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
    return sqrt(dx*dx + dy*dy + dz*dz)                             

                                                                  
import matplotlib
import matplotlib.cm as cm
from matplotlib.colors import Normalize
import matplotlib.image as mimage

                                    
import matplotlib.cm as cm
from matplotlib.colors import Normalize
import matplotlib.image as mimage

def save_image_no_cbar_exact_pixels(array: np.ndarray, basepath: str,
                                    vmin: float=None, vmax: float=None,
                                    cmap_name: str="viridis"):
    img = np.asarray(array)
    if img.ndim != 2:
        img = np.squeeze(img)
    H, W = img.shape
    assert W == IMG_W and H == IMG_H, f"W {IMG_W}x{IMG_H}，H {W}x{H}"

    cmap = cm.get_cmap(cmap_name)
    finite_mask = np.isfinite(img)

                  
    if vmin is None or vmax is None:
        if np.any(finite_mask):
            auto_vmin = float(np.nanmin(img)) if vmin is None else vmin
            auto_vmax = float(np.nanmax(img)) if vmax is None else vmax
            if auto_vmin == auto_vmax:
                auto_vmin -= 1e-6
                auto_vmax += 1e-6
            use_vmin, use_vmax = auto_vmin, auto_vmax
        else:
                           
            use_vmin, use_vmax = 0.0, 1.0
    else:
        use_vmin, use_vmax = float(vmin), float(vmax)
        if use_vmin == use_vmax:
            use_vmin -= 1e-6
            use_vmax += 1e-6

    norm = Normalize(vmin=use_vmin, vmax=use_vmax, clip=True)

                                                            
    mapped = cmap(norm(np.where(finite_mask, img, use_vmin)))        

                                 
    mapped[~finite_mask, 0:3] = 1.0
    mapped[~finite_mask, 3] = 1.0

    mapped_u8 = (np.clip(mapped, 0.0, 1.0) * 255).astype(np.uint8)
    mimage.imsave(basepath + ".png", mapped_u8, format='png')

                                                                    
def save_run_outputs(run: dict):
    tag = run["tag"]
    depth = run["depth_map"]
    depth_base = os.path.join(OUT_DIR, f"depth_map_{tag}")
    np.save(depth_base + ".npy", depth)
    depth_for_png = np.copy(depth)
    finite_mask = np.isfinite(depth_for_png)
    if np.any(finite_mask):
        depth_for_png[finite_mask] = np.clip(depth_for_png[finite_mask], 0.1, 0.9)
    save_image_no_cbar_exact_pixels(depth_for_png, depth_base, vmin=0.1, vmax=0.9, cmap_name="viridis")

                                                                                   
def main():
    ensure_dir(OUT_DIR)
    clear_dir_contents(OUT_DIR)

    run1 = run_once(start_time=0.0, run_name="run1")
    save_run_outputs(run1)

    start2 = float(EXPOSURE + GAP_T)
    run2 = run_once(start_time=start2, run_name="run2")
    save_run_outputs(run2)

                                           
if __name__ == "__main__":
    main()
