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

drawArea = {}

window.onload = () ->
  drawArea = document.getElementById('draw')
  svg = appendSVG(drawArea,'svg',{width: 400; height: 400; viewBox: '0 0 10 10'})
  drawCircle(svg, [5,5], 1)
  svg.setAttribute('viewBox','0 0 7 7')

appendSVG = (container, tag, attrs = {}) ->
  el = document.createElementNS('http://www.w3.org/2000/svg', tag)
  el.setAttribute(k, v) for k, v of attrs
  return container.appendChild(el)

drawCircle = (svg, center, radius, attrs = {class: 'black point'}) ->
  attrs.cx = center[0]
  attrs.cy = center[1]
  attrs.r = radius
  return appendSVG(svg, 'circle', attrs)

drawText = (svg, center, str, attrs = {class: 'black text'}) ->
  attrs.x = center[0]
  attrs.y = center[1]
  text = appendSVG(svg, 'text', attrs)
  text.innerHTML = str
  return text

drawPath = (svg, coords, attrs = {class: 'black line'}) ->
  attrs.d = 'M '
  for c, i in coords
    attrs.d += (if (i != 0) then ' L ' else '') + c[0] + ' ' + c[1]
  return appendSVG(svg, 'path', attrs)

drawCycle = (svg, coords, attrs) ->
  return drawPath(svg, coords.concat([coords[0]]), attrs)

drawPointedCycle = (svg, coords, rad, attrs) ->
  drawCircle(svg, c, rad) for c in coords
  return drawCycle(svg, coords, attrs)

