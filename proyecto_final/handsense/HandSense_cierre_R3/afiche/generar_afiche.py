from pathlib import Path
import base64, html, json, math, shutil
from PIL import Image, ImageFont
import cairosvg
P=Path(__file__).resolve().parent
A=P/'recursos'; A.mkdir(exist_ok=True)
D=P/'resultados.json'
if not D.exists(): D.write_text(json.dumps({'flex_medido':'—','flex_ref':'—','flex_error':'—','fsr_medido':'—','fsr_ref':'—','fsr_error':'—','estado':'Mediciones físicas pendientes','dificultad':'FSR y rango útil del ADC. Se revisan el divisor y las referencias de reposo.','alimentacion':'USB a placa · sensores a 3,3 V · GND común'},ensure_ascii=False,indent=2))
data=json.loads(D.read_text()); W=77/2.54*72; H=55/2.54*72; L=W/4; R=W*3/4; ink='#262038'; purple='#53448F'; soft='#E8E3F5'; bg='#FBF9FE'; muted='#4F4866'; amber='#8A5600'; green='#056641'; line='#CFC7E5'; S=[]
font='/usr/share/fonts/truetype/crosextra/Carlito-Regular.ttf'; bold='/usr/share/fonts/truetype/crosextra/Carlito-Bold.ttf'
def esc(s):return html.escape(str(s))
def width(s,z,b=False): return ImageFont.truetype(bold if b else font,round(z*2)).getlength(s)/2

def txt(x,y,s,z=40,b=False,fill=ink,anchor='start'):
 S.append(f'<text x="{x:.2f}" y="{y:.2f}" fill="{fill}" font-family="Carlito, Calibri, sans-serif" font-size="{z}" font-weight="{700 if b else 400}" text-anchor="{anchor}">{esc(s)}</text>')
def block(x,y,s,maxw,z=40,b=False,fill=ink,leading=1.12):
 for para in s.split('\n'):
  ln=''
  for word in para.split():
   v=(ln+' '+word).strip()
   if ln and width(v,z,b)>maxw: txt(x,y,ln,z,b,fill);y+=z*leading;ln=word
   else:ln=v
  if ln:txt(x,y,ln,z,b,fill);y+=z*leading
 return y

def rect(x,y,w,h,fill=soft,stroke='none',rad=18,sw=2):S.append(f'<rect x="{x:.2f}" y="{y:.2f}" width="{w:.2f}" height="{h:.2f}" rx="{rad}" fill="{fill}" stroke="{stroke}" stroke-width="{sw}"/>')
def arrow(x1,y1,x2,y2,both=False):
 S.append(f'<path d="M{x1:.2f} {y1:.2f} L{x2:.2f} {y2:.2f}" stroke="{purple}" stroke-width="5" fill="none" marker-end="url(#arr)"'+(' marker-start="url(#arrstart)"' if both else '')+'/>')
def img(path,x,y,w,h):
 path=A/path
 with Image.open(path) as im: iw,ih=im.size
 q=min(w/iw,h/ih);iw*=q;ih*=q; x+=(w-iw)/2;y+=(h-ih)/2
 S.append(f'<image x="{x:.2f}" y="{y:.2f}" width="{iw:.2f}" height="{ih:.2f}" href="data:image/png;base64,{base64.b64encode(path.read_bytes()).decode()}"/>')

def box(x,y,w,h,a,b=None):
 rect(x,y,w,h,'#FFFFFF',line,18,3);txt(x+w/2,y+(h/2 if b else h/2+15),a,43,True,purple,'middle')
 if b: txt(x+w/2,y+h/2+38,b,34,False,muted,'middle')
S.append(f'<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="770mm" height="550mm" viewBox="0 0 {W} {H}"><defs><marker id="arr" markerWidth="8" markerHeight="8" refX="7" refY="4" orient="auto"><path d="M0 0 L8 4 L0 8 Z" fill="{purple}"/></marker><marker id="arrstart" markerWidth="8" markerHeight="8" refX="1" refY="4" orient="auto"><path d="M8 0 L0 4 L8 8 Z" fill="{purple}"/></marker></defs>')
rect(0,0,W,H,bg,rad=0);rect(0,0,W,70,purple,rad=0);txt(W/2,47,'Universidad Andrés Bello · Microcontroladores · Ingeniería en Automatización y Robótica · Sede Antonio Varas · 2026',38,True,'#FFFFFF','middle')
for x in (L,R):S.append(f'<path d="M{x} 70 V{H}" stroke="{line}" stroke-dasharray="9 9" stroke-width="2"/>')
# Left: problem and objective
x=32; w=L-64
txt(x,151,'El problema',65,True,purple)
txt(x,213,'EQUIPO HANDSENSE',38,True,amber)
txt(x,263,'María José Córdova',43);txt(x,313,'Alex Díaz Canales',43)
txt(x,394,'¿Qué resolvemos?',50,True,ink)
y=block(x,449,'Flexionar el índice no garantiza que se haya completado una pinza.',w,41)
y=block(x,y+13,'Para quien practica y estudia movimientos de la mano.',w,40,False,muted)
# Hand reference from approved asset
rect(x,700,w,293,soft,rad=24);img('contacto.png',x+10,713,w-20,263)
txt(x+w/2,1039,'Flexión + contacto',40,True,purple,'middle')
rect(x,1080,w,305,purple,rad=22);txt(x+24,1136,'OBJETIVO',40,True,'#FFFFFF')
block(x+24,1190,'Reconocer una pinza completa y comparar la detección por flexión sola y por fusión.',w-48,42,True,'#FFFFFF')
img('unab.png',x,1420,190,80);block(x+205,1449,'Prototipo experimental. Sin validación clínica.',w-205,30,False,muted)
# center
cx=L+32; cw=2*L-64; mid=W/2
# title as largest visual element
z=195
while width('HandSense',z,True)>cw-30:z-=1
txt(mid,250,'HandSense',z,True,ink,'middle');txt(mid,308,'Movimiento con sentido',62,True,purple,'middle');txt(mid,367,'Dos sensores. Una secuencia. Una explicación.',43,True,ink,'middle')
txt(cx,435,'¿Cómo funciona?',63,True,purple)
rect(cx,460,cw,60,'#FFFFFF',line,12);block(cx+16,501,data['alimentacion'],cw-32,37,True,amber)
# 2 sensor boxes
bw=(cw-22)/2
box(cx,545,bw,108,'Flexivo','Divisor 47 kΩ · D1 / GPIO3');box(cx+bw+22,545,bw,108,'FSR','Divisor 10 kΩ · D2 / GPIO4')
arrow(cx+bw/2,655,cx+bw/2,676);arrow(cx+bw+22+bw/2,655,cx+bw+22+bw/2,676)
box(cx,685,cw,99,'ADC1 · 12 bits','0–4095 códigos · rango útil ≈ 0–2,5 V a 11 dB')
arrow(mid,786,mid,810)
rect(cx,818,cw,104,purple,rad=18);txt(mid,862,'XIAO ESP32-C3',51,True,'#FFFFFF','middle');txt(mid,904,'Filtro + calibración NVS + detector por estados',40,False,'#FFFFFF','middle')
# 3 outputs on one row
for i,(a,b) in enumerate([('LED verde','Completa'),('LED ámbar','Incompleta'),('BLE ↔ App','Datos + comandos')]):
 q=(cw-30)/3;xx=cx+i*(q+15);arrow(xx+q/2,924,xx+q/2,945, i==2);box(xx,953,q,91,a,b)
# key decision
rect(cx,1070,cw,197,soft,rad=22);txt(cx+24,1120,'Decisión clave: fusión + calibración',51,True,purple)
txt(cx+24,1169,'Reposo → flexión → contacto → liberación → reposo',40,True,ink)
block(cx+24,1210,'Referencias por usuario · histéresis 60 / 35 % · NVS',cw-48,40,False,muted)
txt(cx+24,1250,'Buzzer opcional: deshabilitado hasta validación eléctrica.',32,False,muted)
# leave lower 10cm clear exactly
# Right
x=R+32;w=L-64
txt(x,151,'La evidencia',65,True,purple)
txt(x,211,'Resultados',49,True,ink)
# Table
cols=[w*.30,w*.25,w*.25,w*.20]; headers=['Sensor','ADC','Ref.','Error']; rowh=53; start=237;rect(x,start,w,rowh,purple,rad=10)
xx=x
for a,cw2 in zip(headers,cols):txt(xx+cw2/2,start+36,a,35,True,'#FFFFFF','middle');xx+=cw2
for j,vals in enumerate([['Flex',data['flex_medido'],data['flex_ref'],data['flex_error']],['FSR',data['fsr_medido'],data['fsr_ref'],data['fsr_error']]]):
 yy=start+rowh*(j+1);rect(x,yy,w,rowh,'#FFFFFF' if j else soft,line,0,2);xx=x
 for a,cw2 in zip(vals,cols):txt(xx+cw2/2,yy+36,a,34,False,ink,'middle');xx+=cw2
block(x,429,'mV · Referencia: multímetro',w,36,False,muted);block(x,476,data['estado'],w,35,True,amber)
txt(x,557,'Nuestra app',52,True,ink)
# actual screenshot cropped from original as screenshot; no manipulation beyond crop if needed
rect(x,582,192,352,'#FFFFFF',purple,16,4);img('app_ble.png',x+8,590,176,336)
block(x+212,628,'Estado y conteo. PING y RESET por BLE.',w-212,41,False,ink)
block(x+212,846,'Captura real de la app.',w-212,32,False,muted)
rect(x,959,w,222,purple,rad=22);txt(x+20,1008,'¡Pruébalo tú!',49,True,'#FFFFFF');block(x+20,1058,'1. Relaja la mano.\n2. Flexiona y toca.\n3. Separa y relaja.',w-40,40,False,'#FFFFFF',1.06)
txt(x,1241,'Lo más difícil',44,True,amber)
block(x,1291,data['dificultad'],w,38,False,ink,1.06)
txt(x,1465,'Versión 2.0',42,True,amber);block(x,1511,'Calibrar desde la app.',w,36,False,ink)
S.append('</svg>');svg=''.join(S).replace(' href="data:', ' xlink:href="data:')
(P/'Afiche_HandSense_77x55.svg').write_text(svg)
cairosvg.svg2pdf(bytestring=svg.encode(),write_to=str(P/'Afiche_HandSense_77x55.pdf'))
cairosvg.svg2png(bytestring=svg.encode(),write_to=str(P/'Vista_previa.png'),output_width=1540,output_height=1100)
