#!/usr/bin/env python3
"""Build an offline macOS Universal 2 app using Apple's command line tools."""
import argparse,pathlib,subprocess,shutil,plistlib,tempfile
p=argparse.ArgumentParser();p.add_argument('--resources',type=pathlib.Path,help='Optional private resource directory');p.add_argument('--output',type=pathlib.Path,default=pathlib.Path('build'));a=p.parse_args()
root=pathlib.Path(__file__).resolve().parents[1];out=a.output.resolve();out.mkdir(parents=True,exist_ok=True);app=out/'诗栖.app';res=app/'Contents/Resources';exe=app/'Contents/MacOS';res.mkdir(parents=True,exist_ok=True);exe.mkdir(parents=True,exist_ok=True)
shutil.copytree(root/'Resources',res,dirs_exist_ok=True,copy_function=shutil.copy)
if a.resources:
 for name in ['library.json','wallpapers.json','data.js','Wallpapers']:
  src=a.resources/name
  if src.is_dir():
   if (res/name).exists():shutil.rmtree(res/name)
   shutil.copytree(src,res/name,copy_function=shutil.copy)
  else:shutil.copy(src,res/name)
info=plistlib.loads((root/'Info.plist').read_bytes());info.update(CFBundleVersion='8',CFBundleShortVersionString='1.4.0',LSArchitecturePriority=['arm64','x86_64'],ShiQiResourceEdition='personal' if a.resources else 'public');(app/'Contents/Info.plist').write_bytes(plistlib.dumps(info))
with tempfile.TemporaryDirectory(prefix='shiqi-build-') as temp:
 bins=[];helpers=[]
 for arch in ['arm64','x86_64']:
  binary=pathlib.Path(temp)/arch;subprocess.run(['xcrun','swiftc',*[str(p) for p in sorted((root/'Sources').glob('*.swift'))],'-target',arch+'-apple-macosx13.0','-O','-o',str(binary),'-framework','Cocoa','-framework','WebKit','-framework','AVFoundation','-framework','ServiceManagement','-module-cache-path',temp+'/cache'],check=True);bins.append(str(binary))
  helper=pathlib.Path(temp)/('updater-'+arch);subprocess.run(['xcrun','swiftc',str(root/'Updater/main.swift'),'-target',arch+'-apple-macosx13.0','-O','-o',str(helper),'-framework','Cocoa','-module-cache-path',temp+'/cache'],check=True);helpers.append(str(helper))
 subprocess.run(['lipo','-create',*bins,'-output',str(exe/'ShiQi')],check=True)
 subprocess.run(['lipo','-create',*helpers,'-output',str(exe/'ShiQiUpdater')],check=True)
(exe/'ShiQiUpdater').chmod(0o755)
subprocess.run(['codesign','--force','--sign','-',str(exe/'ShiQiUpdater')],check=True)
(exe/'ShiQi').chmod(0o755)
subprocess.run(['codesign','--force','--deep','--sign','-',str(app)],check=True)
subprocess.run(['codesign','--verify','--deep','--strict',str(app)],check=True)
subprocess.run(['lipo',str(exe/'ShiQi'),'-verify_arch','arm64','x86_64'],check=True)
subprocess.run(['lipo',str(exe/'ShiQiUpdater'),'-verify_arch','arm64','x86_64'],check=True)
print(app)
