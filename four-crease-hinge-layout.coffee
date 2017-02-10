# Generic Code

XHTMLNS = 'http://www.w3.org/1999/xhtml'
SVGNS = 'http://www.w3.org/2000/svg'
EPS = 0.000000001
[PI, COS, SIN, TAN, SQRT, ACOS, ATAN, ABS, FLOOR, MAX, MIN] =
  (Math[i] for i in ['PI','cos','sin','tan','sqrt',
    'acos','atan2','abs','floor','max','min'])
sum = (a,b) -> a + b
cat = (a,b) -> a.concat(b)
mod = (i,n) -> i - FLOOR(i / n) * n
cyc = (v,i) -> v[mod(i, v.length)]
mul = (v,a) -> (i * a for i in v)
div = (v,a) -> (mul(v, 1 / a) if a isnt 0)
plus = (v,w) -> (vi + w[i] for vi, i in v)
sub = (v,w) -> (vi - w[i] for vi, i in v)
dot = (v,w) -> (vi * w[i] for vi, i in v).reduce(sum)
magsq = (v) -> dot(v,v)
mag = (v) -> SQRT(dot(v,v))
unit = (v) -> div(v, mag(v))
distsq = (v,w) -> magsq(sub(v,w))
dist = (v,w) -> mag(sub(v,w))
dir = (v,w) -> unit(sub(w,v))
ang = (v,w) -> ACOS(dot(unit(v),unit(w)))
uAng = (a) -> [COS(a), SIN(a)]
rot = (v,u,t) ->
  [ct, st] = uAng(t)
  (for p in [[0,1,2],[1,2,0],[2,0,1]]
    (for q, i in [ct, -st * u[p[2]], st * u[p[1]]]
      v[p[i]] * (u[p[0]] * u[p[i]] * (1 - ct) + q)).reduce(sum))
rot2D = (v,t) -> rot(v.concat(0),[0,0,1],t).slice(0,-1)
getId = (id) -> document.getElementById(id)
createNS = (namespace, tag, attrs) ->
  el = document.createElementNS(namespace, tag)
  setAttrs(el, attrs)
createXHTML = (tag, attrs) -> createNS(XHTMLNS, tag, attrs)
createSVG   = (tag, attrs) -> createNS(  SVGNS, tag, attrs)
setAttrs = (el, attrs = {}) -> el.setAttribute(k, v) for k, v of attrs; el
makePath = (coords) ->
  s = ("#{if (i is 0) then 'M' else 'L'} #{c[0]} #{c[1]} " for c, i in coords)
  s.reduce(sum)
makeCycle = (coords) -> makePath(coords) + 'Z'

# Application Specific

showF = true
showB = true
showS = true
showC = true

makeSector = (start, diff) ->
  (if diff > PI / 2
     [[0,0], uAng(start), div(uAng(start + diff/4), COS(diff/4)),
       div(uAng(start + diff*3/4), COS(diff/4)), uAng(start + diff)]
   else
     [[0,0], uAng(start), div(uAng(start + diff/2), COS(diff/2)),
       uAng(start + diff)]
  )

offsetCorner = (qs, t) ->
  ps = qs.slice()
  [p2,p1,o,n1,n2] = (cyc(ps, i) for i in [-2, -1, 0, 1, 2])
  [u2,u1,v1,v2] = (dir(i, j) for [i,j] in [[p1,p2],[o,p1],[o,n1],[n1,n2]])
  u = unit(plus(v1, mul(sub(u1, v1), 0.5)))
  ps[0] = plus(ps[0], mul(u, t / SIN(ang(u, v1))))
  ps[1] = plus(ps[1], mul(v2, t))
  ps[ps.length - 1] = plus(cyc(ps,-1), mul(u2, t))
  ps

update = () ->
  a = getId('aR').value * PI / 2
  b = a + getId('bR').value * (PI - 2 * a)
  r = getId('rR').value * PI / 2
  t = getId('tR').value * TAN(a/2) / 4
  t1 = t*SIN(r)
  t2 = t*SIN(2*Math.atan(TAN(r/2)*SIN((b - a)/2)/SIN((b + a)/2)))
  getId('aL').innerHTML = (a*180/PI).toFixed(2)
  getId('bL').innerHTML = (b*180/PI).toFixed(2)
  getId('tL').innerHTML = t.toFixed(2)
  getId('rL').innerHTML = r.toFixed(2)

  f1 = makeSector(0, a)
  f2 = makeSector(a, b)
  f3 = makeSector(a + b, PI - a)
  f4 = makeSector(PI + b, PI - b)
  getId('l1').setAttribute('d', makeCycle(f1))
  getId('l2').setAttribute('d', makeCycle(f2))
  getId('l3').setAttribute('d', makeCycle(f3))
  getId('l4').setAttribute('d', makeCycle(f4))
  getId('u1').setAttribute('d', makeCycle(offsetCorner(f1,t)))
  getId('u2').setAttribute('d', makeCycle(offsetCorner(f2,t)))
  getId('u3').setAttribute('d', makeCycle(offsetCorner(f3,t)))
  getId('u4').setAttribute('d', makeCycle(offsetCorner(f4,t)))
  getId('s1').setAttribute('d', makeCycle(offsetCorner(f1,t1)))
  getId('s2').setAttribute('d', makeCycle(offsetCorner(f2,t1)))
  getId('s3').setAttribute('d', makeCycle(offsetCorner(f3,t1)))
  getId('s4').setAttribute('d', makeCycle(offsetCorner(f4,t1)))
  getId('t1').setAttribute('d', makeCycle(offsetCorner(f1,t2)))
  getId('t2').setAttribute('d', makeCycle(offsetCorner(f2,t2)))
  getId('t3').setAttribute('d', makeCycle(offsetCorner(f3,t2)))
  getId('t4').setAttribute('d', makeCycle(offsetCorner(f4,t2)))

  [u1, u2, u3, u4] = (unit(f[1]) for f in [f1, f2, f3, f4])
  [v1, v2, v3, v4] = (dir(f[1], f[2]) for f in [f1, f2, f3, f4])
  x = t1 / TAN(a/2)

  p1 = plus(cyc(f1,-1),mul(v2,-t1))
  p2 = plus(p1, mul(u2,-x))
  p3 = plus(p2, mul(v2,t1))
  p4 = mul(u2, x)
  p5 = plus(p4, mul(v2, -t1))
  p6 = mul(u1, t1 / SIN(a))
  ps = [p1, p2, p3, p4, p5, p6].concat(f1.slice(1,-1))
  getId('a1').setAttribute('d', makeCycle(ps))
  p1 = plus(cyc(f2,-1), mul(u3,-x))
  p2 = plus(p1, mul(v3,-t2))
  p4 = mul(u3, x)
  p3 = plus(p4, mul(v3,-t2))
  p5 = mul(u2, x)
  p6 = plus(p5, mul(v2, t1))
  p8 = plus(f2[1], mul(u2,-x))
  p7 = plus(p8, mul(v2, t1))
  ps = [p1, p2, p3, p4, [0,0], p5, p6, p7, p8].concat(f2.slice(1))
  getId('a2').setAttribute('d', makeCycle(ps))
  p1 = plus(cyc(f3,-1), mul(u4,-x))
  p2 = plus(p1, mul(v4,-t1))
  p6 = plus(mul(v3, t2), mul(u3, -MAX(0, t2 * TAN(b - PI/2))))
  p4 = mul(u4, x)
  p3 = plus(p4, mul(v4,-t1))
  p5 = mul(u4, dot(p6,u4))
  p8 = mul(u3, x)
  p7 = plus(p8, mul(v3, t2))
  p9 = plus(f3[1], mul(u3,-x))
  p10 = plus(p9, mul(v3, t2))
  p11 = plus(f3[1], mul(v3, t2))
  ps = [p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11].concat(f3.slice(2))
  getId('a3').setAttribute('d', makeCycle(ps))
  p1 = mul(u1, t1 / SIN(a))
  p2 = mul(uAng((a + b - PI)/2), t1/SIN((PI - b + a)/2))
  p4 = mul(u4, x)
  p3 = plus(p4, mul(v4, t1))
  p5 = mul(u4, 1-x)
  p6 = plus(p5, mul(v4, t1))
  p7 = plus(f4[1], mul(v4, t1))
  ps = [p1, p2, p3, p4, p5, p6, p7].concat(f4.slice(1))
  getId('a4').setAttribute('d', makeCycle(ps))

  p2 = mul(u1, MAX(0, t2 / TAN(PI - b)))
  p1 = mul(u2, MAX(0, t2 / TAN(PI - b)) / COS(a))
  p3 = mul(u1, x)
  p4 = plus(p3, mul(v1,t2))
  p5 = plus(mul(f1[1], 1 - x), mul(v1,t2))
  p6 = plus(p5, mul(v1,-t2))
  ps = [p1, p2, p3, p4, p5, p6].concat(f1.slice(1))
  getId('b1').setAttribute('d', makeCycle(ps))
  getId('b2').setAttribute('d', makeCycle(f2))
  getId('b3').setAttribute('d', makeCycle(f3))
  p1 = plus(cyc(f4,-1), mul(v1,-t2))
  p2 = plus(p1, mul(u1,-x))
  p3 = plus(p2, mul(v1,t2))
  p4 = mul(u1, x)
  p5 = plus(p4, mul(v1,-t2))
  p6 = mul(u4, t2 / SIN(PI - b))
  ps = [p1, p2, p3, p4, p5, p6].concat(f4.slice(1,-1))
  getId('b4').setAttribute('d', makeCycle(ps))

  rad = t/2 * 0.95
  [p1, p2, p3, p4] = (for [u,v] in [[u1,u2], [u2,u3], [u3,u4], [u4,u1]]
    mul(unit(plus(u,v)), (t1 + t)/SIN(ang(u,v)/2)))
  setAttrs(getId('c11'),{r: rad, cx: p1[0],cy: p1[1]})
  setAttrs(getId('c21'),{r: rad, cx: p2[0],cy: p2[1]})
  setAttrs(getId('c31'),{r: rad, cx: p3[0],cy: p3[1]})
  setAttrs(getId('c41'),{r: rad, cx: p4[0],cy: p4[1]})

  [p1, p2, p3, p4] = (for [u,v] in [[u1,v1], [u2,v2], [u3,v3], [u4,v4]]
    plus(mul(v, t + t1), mul(u, 1 - t)))
  setAttrs(getId('c12'),{r: rad, cx: p1[0],cy: p1[1]})
  setAttrs(getId('c22'),{r: rad, cx: p2[0],cy: p2[1]})
  setAttrs(getId('c32'),{r: rad, cx: p3[0],cy: p3[1]})
  setAttrs(getId('c42'),{r: rad, cx: p4[0],cy: p4[1]})

  [p1, p2, p3, p4] = (for [u,v] in [[u1,v1], [u2,v2], [u3,v3], [u4,v4]]
    plus(mul(v, -t - t1), mul(u, 1 - t)))
  setAttrs(getId('c13'),{r: rad, cx: p1[0],cy: p1[1]})
  setAttrs(getId('c23'),{r: rad, cx: p2[0],cy: p2[1]})
  setAttrs(getId('c33'),{r: rad, cx: p3[0],cy: p3[1]})
  setAttrs(getId('c43'),{r: rad, cx: p4[0],cy: p4[1]})
  
  getId('frontG').setAttribute('visibility',
    (if showF then 'visible' else 'hidden'))
  getId('backG').setAttribute('visibility',
    (if showB then 'visible' else 'hidden'))
  getId('sketchG').setAttribute('visibility',
    (if showS then 'visible' else 'hidden'))
  getId('circleG').setAttribute('visibility',
    (if showC then 'visible' else 'hidden'))

window.onload = () ->
  svg = getId('draw').appendChild(createSVG('svg', {
    id: 'svg', class: 'svg', xmlns: SVGNS,
    width: 600, height: 600, viewBox: '-1.5 -1.5 3 3' }))

  styles = '.svg { background-color: white; }
    .circle { fill: #FFFFFF; }
    .blue { fill: #0000FF; fill-opacity: 0.3; }
    .red { fill: #FF0000; fill-opacity: 0.3; }
    .line { stroke-width: 0.01; stroke-linejoin: round; }
    .line.nofill { fill: none }
    .line.K { stroke: #000000; }
    .line.R { stroke: #FF0000; }
    .line.G { stroke: #00FF00; }
    .line.B { stroke: #0000FF; }'
  svg.appendChild(createXHTML('style', {type: 'text/css'})).innerHTML = styles

  backG = svg.appendChild(createSVG('g', {id: 'backG'}))
  backG.appendChild(createSVG('path', {id: 'b1', class: 'K line fill red' }))
  backG.appendChild(createSVG('path', {id: 'b2', class: 'K line fill red' }))
  backG.appendChild(createSVG('path', {id: 'b3', class: 'K line fill red' }))
  backG.appendChild(createSVG('path', {id: 'b4', class: 'K line fill red' }))

  frontG = svg.appendChild(createSVG('g', {id: 'frontG'}))
  frontG.appendChild(createSVG('path', {id: 'a1', class: 'K line fill blue' }))
  frontG.appendChild(createSVG('path', {id: 'a2', class: 'K line fill blue' }))
  frontG.appendChild(createSVG('path', {id: 'a3', class: 'K line fill blue' }))
  frontG.appendChild(createSVG('path', {id: 'a4', class: 'K line fill blue' }))

  circleG = svg.appendChild(createSVG('g', {id: 'circleG'}))
  circleG.appendChild(createSVG('circle', {id: 'c11', class: 'K line circle' }))
  circleG.appendChild(createSVG('circle', {id: 'c21', class: 'K line circle' }))
  circleG.appendChild(createSVG('circle', {id: 'c31', class: 'K line circle' }))
  circleG.appendChild(createSVG('circle', {id: 'c41', class: 'K line circle' }))
  circleG.appendChild(createSVG('circle', {id: 'c12', class: 'K line circle' }))
  circleG.appendChild(createSVG('circle', {id: 'c22', class: 'K line circle' }))
  circleG.appendChild(createSVG('circle', {id: 'c32', class: 'K line circle' }))
  circleG.appendChild(createSVG('circle', {id: 'c42', class: 'K line circle' }))
  circleG.appendChild(createSVG('circle', {id: 'c13', class: 'K line circle' }))
  circleG.appendChild(createSVG('circle', {id: 'c23', class: 'K line circle' }))
  circleG.appendChild(createSVG('circle', {id: 'c33', class: 'K line circle' }))
  circleG.appendChild(createSVG('circle', {id: 'c43', class: 'K line circle' }))

  sketchG = svg.appendChild(createSVG('g', {id: 'sketchG'}))
  sketchG.appendChild(createSVG('path', {id: 's1', class: 'R line nofill' }))
  sketchG.appendChild(createSVG('path', {id: 's2', class: 'R line nofill' }))
  sketchG.appendChild(createSVG('path', {id: 's3', class: 'R line nofill' }))
  sketchG.appendChild(createSVG('path', {id: 's4', class: 'R line nofill' }))
  sketchG.appendChild(createSVG('path', {id: 't1', class: 'B line nofill' }))
  sketchG.appendChild(createSVG('path', {id: 't2', class: 'B line nofill' }))
  sketchG.appendChild(createSVG('path', {id: 't3', class: 'B line nofill' }))
  sketchG.appendChild(createSVG('path', {id: 't4', class: 'B line nofill' }))
  sketchG.appendChild(createSVG('path', {id: 'u1', class: 'G line nofill' }))
  sketchG.appendChild(createSVG('path', {id: 'u2', class: 'G line nofill' }))
  sketchG.appendChild(createSVG('path', {id: 'u3', class: 'G line nofill' }))
  sketchG.appendChild(createSVG('path', {id: 'u4', class: 'G line nofill' }))
  sketchG.appendChild(createSVG('path', {id: 'l1', class: 'K line nofill' }))
  sketchG.appendChild(createSVG('path', {id: 'l2', class: 'K line nofill' }))
  sketchG.appendChild(createSVG('path', {id: 'l3', class: 'K line nofill' }))
  sketchG.appendChild(createSVG('path', {id: 'l4', class: 'K line nofill' }))

  getId('aR').addEventListener('input', () -> update())
  getId('bR').addEventListener('input', () -> update())
  getId('rR').addEventListener('input', () -> update())
  getId('tR').addEventListener('input', () -> update())
  getId( 'front').addEventListener('click', () -> showF = !showF; update())
  getId(  'back').addEventListener('click', () -> showB = !showB; update())
  getId('sketch').addEventListener('click', () -> showS = !showS; update())
  getId('circle').addEventListener('click', () -> showC = !showC; update())

  update()
