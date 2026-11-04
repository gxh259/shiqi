import zipfile,glob,xml.etree.ElementTree as ET,json,pathlib,shutil,collections,argparse
p=argparse.ArgumentParser();p.add_argument("epub",type=pathlib.Path);p.add_argument("wallpapers",type=pathlib.Path);p.add_argument("output",type=pathlib.Path);args=p.parse_args()
root=args.output;root.mkdir(parents=True,exist_ok=True)
z=zipfile.ZipFile(args.epub); result=[]
for filename in z.namelist():
 if not filename.endswith('.html'): continue
 tree=ET.fromstring(z.read(filename)); title=''; author=''; lines=[]; category=''; active=False; analysis=[]
 def flush():
  if title and author and lines:
   result.append(dict(id=len(result),title=title,author=author,body='\n'.join(lines),category=category,source=filename,analysis='\n\n'.join(analysis)))
 for e in tree.iter():
  tag=e.tag.split('}')[-1]; cls=e.get('class',''); t=''.join(e.itertext()).strip()
  if cls=='title-poem-k-zhong' or (tag=='h2' and cls in ['calibre20','kindle-cn-heading1']):
   flush(); title=t; author='';lines=[];analysis=[];active=True;category='唐诗' if cls=='title-poem-k-zhong' else ('宋词' if cls=='calibre20' else '元曲')
  elif active and cls in ['shuming1','shuming','kindle-cn-para-right1'] and not lines: author=t
  elif active and author and cls in ['kai_long','kai_long1','yinwen','yinwen1','tzshort','tzlong','tzshort1','kindle-cn-kai'] and t and not analysis: lines.append(t)
  elif active and lines and tag=='p' and t:
   analysis.append(t)
 flush()
(root/'library.json').write_text(json.dumps(result,ensure_ascii=False))
w=root/'Wallpapers';w.mkdir(exist_ok=True)
files=sorted(p for p in args.wallpapers.iterdir() if p.suffix.lower() in ['.jpg','.jpeg','.png','.heic','.webp'])
for p in files: shutil.copy2(p,w/p.name)
(root/'wallpapers.json').write_text(json.dumps([p.name for p in files]))
print('导入',len(result),'篇',collections.Counter(p['category'] for p in result),'壁纸',len(files))

(root/"data.js").write_text("const LIBRARY="+(root/"library.json").read_text()+";\nconst WALLPAPERS="+(root/"wallpapers.json").read_text()+";")
