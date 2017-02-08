EPS = 0.000000001

sum = (a,b) -> return a + b
max = (a,b) -> return Math.max(a, b)
min = (a,b) -> return Math.min(a, b)
concat = (a,b) -> return a.concat(b)

STYLES =
  '.line  { fill: none; 
            stroke-width: 3; 
            stroke-linecap: round; 
            stroke-linejoin: round; }
   .line.red   { stroke: red; }
   .line.blue  { stroke: blue; }
   .line.black { stroke: black; }
   .point { stroke: none; }
   .point.red   { fill: red; }
   .point.blue  { fill: blue; }
   .point.black { fill: black; }
   .text { font-family: monospace; font-size: 10; }
   .text.red   { fill: red; }
   .text.blue  { fill: blue; }
   .text.black { fill: black; }
   .svg { border-style: solid;
          border-width: 2px; 
          background-color: #EEE; }'

mat1 = {
  width: 340
  height: 200
  origin: [30,30]
  scale: [260,50]
}
mat2 = {
  width: 340
  height: 200
  origin: [30,30]
  scale: [260,130]
}
mat3 = {
  width: 340
  height: 200
  origin: [30,30]
  scale: [260,50]
}
mat4 = {
  width: 340
  height: 200
  origin: [30,30]
  scale: [260,130]
}

submitButton = {}
textButton = {}
prevButton = {}
nextButton = {}
drawArea = {}
irrationalField = {}
coeffsField = {}
sepField = {}
errorField = {}

textOn = true
arrayIdx = 0
arrayLength = 1

window.onload = () ->
  submitButton    = document.getElementById('submit')
  textButton      = document.getElementById('textToggle')
  prevButton      = document.getElementById('prev')
  nextButton      = document.getElementById('next')
  drawArea        = document.getElementById('draw')
  irrationalField = document.getElementById('irrational')
  coeffsField     = document.getElementById('coeffs')
  sepField        = document.getElementById('sep')
  errorField      = document.getElementById('error')

  irrationalField.value = "#{E}"
  coeffsField.value =
    '[[[4,-1],[1,0],[0,1],[3,0]], 
     [[4,-1],[1,-0.25],[0,0.25],[0,0.25],[0,0.75],[3,0]], 
     [[4,-1],[1,-0.25], [0,0.5],[0,0.25],[0,0.5],[3,0]], 
     [[4,-1],[1,-0.25],[0,0.75],[0,0.25],[0,0.25],[3,0]], 
     [[4,-1],[1,-0.25],[0,1],[3,0.25]], 
     [[3,-0.75],[1,-0.25],[1,0.75],[3,0.25]], 
     [[2,-0.5],[1,-0.25],[2,0.5],[3,0.25]], 
     [[1,-0.25],[1,-0.25],[3,0.25],[3,0.25]], 
     [[4,0],[4,0]]]'
  prevButton.value = "Prev"
  nextButton.value = "[#{arrayIdx}] Next"
  sepField.value = '0.3'

  addSVG(mat1, appendSVG(drawArea, 'svg'))
  addSVG(mat2, appendSVG(drawArea, 'svg'))
  addSVG(mat3, appendSVG(drawArea, 'svg'))
  addSVG(mat4, appendSVG(drawArea, 'svg'))

  update()

  submitButton.addEventListener('click', () =>
    arrayIdx = 0
    arrayLength = 1
    update()
  )
  textButton.addEventListener('click', () =>
    textOn = not textOn
    update()
  )
  prevButton.addEventListener('click', () =>
    arrayIdx = (arrayIdx + arrayLength - 1) % arrayLength
    prevButton.value = "Prev"
    update()
  )
  nextButton.addEventListener('click', () =>
    arrayIdx = (arrayIdx + 1) % arrayLength
    nextButton.value = "[#{arrayIdx}] Next"
    update()
  )
  return null

update = () ->
  errorField.innerHTML = ''
  if not (irr = tryParseJSON(irrationalField, 'x = ')) then return
  if not (sep = tryParseJSON(sepField, 'Seperation ')) then return
  if not (data = tryParseJSON(coeffsField, 'Length ')) then return
  arrayLength = data.length

  clearSVG(mat1.svg)
  clearSVG(mat2.svg)
  clearSVG(mat3.svg)
  clearSVG(mat4.svg)
  
  cs = data[(arrayIdx + arrayLength - 1) % arrayLength]
  input = {basis: [1,irr], coeffs: cs}
  drawFlat(mat1, input, sep, {class: 'red line'})
  drawTwoBasis(mat2, input, {class: ' red line'})

  input.coeffs = data[arrayIdx]
  drawFlat(mat3, input, sep, {class: 'blue line'})
  drawTwoBasis(mat4, input, {class: 'blue line'})

tryParseJSON = (field, str) ->
  try
    value = JSON.parse(field.value)
  catch error
    errorField.innerHTML = "#{str} input not valid"
    return false
  return value
  
clearSVG = (svg) -> svg.removeChild(svg.children[1]) while (svg.children[1])

toValues = (ratBasArray) ->
  return (for c in ratBasArray.coeffs
    (c[i] * b for b, i in ratBasArray.basis).reduce(sum)
  )

evenSum = (array) ->
  return (d for d, i in array when (i % 2) is 0).reduce(sum)

drawTwoBasis = (mat, ratBasArray, attrs) ->
  dists = toValues(ratBasArray)
  dists = ((if (i % 2) is 0 then d else -d) for d, i in dists)
  if Math.abs(dists.reduce(sum)) > EPS # not flat foldable
    errorField.innerHTML = 'Input is not flat foldable'
    return
  loc = [0,0]
  coords = (for [x,y], i in ratBasArray.coeffs
    sgn = if (i % 2) is 0 then 1 else -1
    loc = [loc[0] + x * sgn, loc[1] + y * sgn]
    loc
  )
  minX = (d[0] for d in coords).reduce(min)
  maxX = (d[0] for d in coords).reduce(max)
  width = maxX - minX
  minY = (d[1] for d in coords).reduce(min)
  maxY = (d[1] for d in coords).reduce(max)
  height = maxY - minY
  scale = Math.max(width, height)
  coords_ = ([(x - minX) / scale, (y - minY) / scale] for [x,y] in coords)
  drawPointedCycle(mat, coords_, 3, attrs)
  drawCircle(mat, [-minX / scale, -minY / scale], 5, {class: 'red point'})
  for c, i in coords when textOn
    anchor = coords_[i]
    anchor[1] += 0.03
    drawText(mat, anchor, "[#{c[0]},#{c[1]}]")
  return null

drawFlat = (mat, ratBasArray, sep, attrs) ->
  dists = toValues(ratBasArray)
  dists = ((if (i % 2) is 0 then d else -d) for d, i in dists)
  if Math.abs(dists.reduce(sum)) > EPS # not flat foldable
    errorField.innerHTML = 'Input is not flat foldable'
    return
  width = evenSum(dists)
  loc = 0
  pts = (for d, i in dists
    loc += d
    [[loc / width, i * sep], [loc / width, (i + 1) * sep]]
  ).reduce(concat)
  pts[pts.length-1][1] = 0
  drawPointedCycle(mat, pts, 3, attrs)
  drawCircle(mat, [0, 0], 5, {class: 'red point'})
  loc = [0,0]
  coords = (for [x,y], i in ratBasArray.coeffs
    sgn = if (i % 2) is 0 then 1 else -1
    loc = [loc[0] + x * sgn, loc[1] + y * sgn]
    loc
  )
  for c, i in coords when textOn
    anchor = pts[2 * i]
    anchor[0] += 0.01
    anchor[1] += 0.1
    drawText(mat, anchor, "[#{c[0]},#{c[1]}]: #{(c[0] + c[1] * E).toFixed(2)}")
  return null

addSVG = (mat, svg) ->
  mat.svg = svg
  mat.width = 500 if not mat.width?
  mat.height = 500 if not mat.width?
  mat.svg.setAttribute('width', mat.width)
  mat.svg.setAttribute('height', mat.height)
  mat.svg.setAttribute('class','svg')
  mat.svg.setAttribute('xmlns','http://www.w3.org/2000/svg')
  mat.style = mat.svg.appendChild(document.createElement('style'))
  mat.style.setAttribute('type','text/css')
  mat.style.innerHTML = STYLES
  return mat

align = (mat, pt) ->
  return [pt[0] * mat.scale[0] + mat.origin[0],
         -pt[1] * mat.scale[1] - mat.origin[1] + mat.height]

appendSVG = (container, tag, attrs = {}) ->
  el = document.createElementNS('http://www.w3.org/2000/svg', tag)
  el.setAttribute(k, v) for k, v of attrs
  return container.appendChild(el)

drawCircle = (mat, center, radius, attrs = {class: 'black point'}) ->
  c = align(mat,center)
  attrs.cx = c[0]
  attrs.cy = c[1]
  attrs.r = radius
  return appendSVG(mat.svg, 'circle', attrs)

drawText = (mat, center, str, attrs = {class: 'black text'}) ->
  c = align(mat,center)
  attrs.x = c[0]
  attrs.y = c[1]
  svg = appendSVG(mat.svg, 'text', attrs)
  svg.innerHTML = str
  return svg

drawPath = (mat, coords, attrs = {class: 'black line'}) ->
  attrs.d = 'M '
  for c, i in coords
    p = align(mat, c)
    attrs.d += (if (i != 0) then ' L ' else '') + p[0] + ' ' + p[1]
  return appendSVG(mat.svg, 'path', attrs)

drawCycle = (mat, coords, attrs) ->
  return drawPath(mat, coords.concat([coords[0]]), attrs)

drawPointedCycle = (mat, coords, rad, attrs) ->
  drawCircle(mat, c, rad) for c in coords
  return drawCycle(mat, coords, attrs)

