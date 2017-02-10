// Generated by CoffeeScript 1.10.0
(function() {
  var ABS, ACOS, ATAN, COS, EPS, FLOOR, MAX, MIN, PI, SIN, SQRT, SVGNS, TAN, XHTMLNS, ang, cat, createNS, createSVG, createXHTML, cyc, dir, dist, distsq, div, dot, getId, i, mag, magsq, makeCycle, makePath, makeSector, mod, mul, offsetCorner, plus, ref, rot, rot2D, setAttrs, showB, showC, showF, showS, sub, sum, uAng, unit, update;

  XHTMLNS = 'http://www.w3.org/1999/xhtml';

  SVGNS = 'http://www.w3.org/2000/svg';

  EPS = 0.000000001;

  ref = (function() {
    var l, len, ref, results;
    ref = ['PI', 'cos', 'sin', 'tan', 'sqrt', 'acos', 'atan2', 'abs', 'floor', 'max', 'min'];
    results = [];
    for (l = 0, len = ref.length; l < len; l++) {
      i = ref[l];
      results.push(Math[i]);
    }
    return results;
  })(), PI = ref[0], COS = ref[1], SIN = ref[2], TAN = ref[3], SQRT = ref[4], ACOS = ref[5], ATAN = ref[6], ABS = ref[7], FLOOR = ref[8], MAX = ref[9], MIN = ref[10];

  sum = function(a, b) {
    return a + b;
  };

  cat = function(a, b) {
    return a.concat(b);
  };

  mod = function(i, n) {
    return i - FLOOR(i / n) * n;
  };

  cyc = function(v, i) {
    return v[mod(i, v.length)];
  };

  mul = function(v, a) {
    var l, len, results;
    results = [];
    for (l = 0, len = v.length; l < len; l++) {
      i = v[l];
      results.push(i * a);
    }
    return results;
  };

  div = function(v, a) {
    if (a !== 0) {
      return mul(v, 1 / a);
    }
  };

  plus = function(v, w) {
    var l, len, results, vi;
    results = [];
    for (i = l = 0, len = v.length; l < len; i = ++l) {
      vi = v[i];
      results.push(vi + w[i]);
    }
    return results;
  };

  sub = function(v, w) {
    var l, len, results, vi;
    results = [];
    for (i = l = 0, len = v.length; l < len; i = ++l) {
      vi = v[i];
      results.push(vi - w[i]);
    }
    return results;
  };

  dot = function(v, w) {
    var vi;
    return ((function() {
      var l, len, results;
      results = [];
      for (i = l = 0, len = v.length; l < len; i = ++l) {
        vi = v[i];
        results.push(vi * w[i]);
      }
      return results;
    })()).reduce(sum);
  };

  magsq = function(v) {
    return dot(v, v);
  };

  mag = function(v) {
    return SQRT(dot(v, v));
  };

  unit = function(v) {
    return div(v, mag(v));
  };

  distsq = function(v, w) {
    return magsq(sub(v, w));
  };

  dist = function(v, w) {
    return mag(sub(v, w));
  };

  dir = function(v, w) {
    return unit(sub(w, v));
  };

  ang = function(v, w) {
    return ACOS(dot(unit(v), unit(w)));
  };

  uAng = function(a) {
    return [COS(a), SIN(a)];
  };

  rot = function(v, u, t) {
    var ct, l, len, p, q, ref1, ref2, results, st;
    ref1 = uAng(t), ct = ref1[0], st = ref1[1];
    ref2 = [[0, 1, 2], [1, 2, 0], [2, 0, 1]];
    results = [];
    for (l = 0, len = ref2.length; l < len; l++) {
      p = ref2[l];
      results.push(((function() {
        var len1, m, ref3, results1;
        ref3 = [ct, -st * u[p[2]], st * u[p[1]]];
        results1 = [];
        for (i = m = 0, len1 = ref3.length; m < len1; i = ++m) {
          q = ref3[i];
          results1.push(v[p[i]] * (u[p[0]] * u[p[i]] * (1 - ct) + q));
        }
        return results1;
      })()).reduce(sum));
    }
    return results;
  };

  rot2D = function(v, t) {
    return rot(v.concat(0), [0, 0, 1], t).slice(0, -1);
  };

  getId = function(id) {
    return document.getElementById(id);
  };

  createNS = function(namespace, tag, attrs) {
    var el;
    el = document.createElementNS(namespace, tag);
    return setAttrs(el, attrs);
  };

  createXHTML = function(tag, attrs) {
    return createNS(XHTMLNS, tag, attrs);
  };

  createSVG = function(tag, attrs) {
    return createNS(SVGNS, tag, attrs);
  };

  setAttrs = function(el, attrs) {
    var k, v;
    if (attrs == null) {
      attrs = {};
    }
    for (k in attrs) {
      v = attrs[k];
      el.setAttribute(k, v);
    }
    return el;
  };

  makePath = function(coords) {
    var c, s;
    s = (function() {
      var l, len, results;
      results = [];
      for (i = l = 0, len = coords.length; l < len; i = ++l) {
        c = coords[i];
        results.push((i === 0 ? 'M' : 'L') + " " + c[0] + " " + c[1] + " ");
      }
      return results;
    })();
    return s.reduce(sum);
  };

  makeCycle = function(coords) {
    return makePath(coords) + 'Z';
  };

  showF = true;

  showB = true;

  showS = true;

  showC = true;

  makeSector = function(start, diff) {
    if (diff > PI / 2) {
      return [[0, 0], uAng(start), div(uAng(start + diff / 4), COS(diff / 4)), div(uAng(start + diff * 3 / 4), COS(diff / 4)), uAng(start + diff)];
    } else {
      return [[0, 0], uAng(start), div(uAng(start + diff / 2), COS(diff / 2)), uAng(start + diff)];
    }
  };

  offsetCorner = function(qs, t) {
    var j, n1, n2, o, p1, p2, ps, ref1, ref2, u, u1, u2, v1, v2;
    ps = qs.slice();
    ref1 = (function() {
      var l, len, ref1, results;
      ref1 = [-2, -1, 0, 1, 2];
      results = [];
      for (l = 0, len = ref1.length; l < len; l++) {
        i = ref1[l];
        results.push(cyc(ps, i));
      }
      return results;
    })(), p2 = ref1[0], p1 = ref1[1], o = ref1[2], n1 = ref1[3], n2 = ref1[4];
    ref2 = (function() {
      var l, len, ref2, ref3, results;
      ref2 = [[p1, p2], [o, p1], [o, n1], [n1, n2]];
      results = [];
      for (l = 0, len = ref2.length; l < len; l++) {
        ref3 = ref2[l], i = ref3[0], j = ref3[1];
        results.push(dir(i, j));
      }
      return results;
    })(), u2 = ref2[0], u1 = ref2[1], v1 = ref2[2], v2 = ref2[3];
    u = unit(plus(v1, mul(sub(u1, v1), 0.5)));
    ps[0] = plus(ps[0], mul(u, t / SIN(ang(u, v1))));
    ps[1] = plus(ps[1], mul(v2, t));
    ps[ps.length - 1] = plus(cyc(ps, -1), mul(u2, t));
    return ps;
  };

  update = function() {
    var a, b, f, f1, f2, f3, f4, p1, p10, p11, p2, p3, p4, p5, p6, p7, p8, p9, ps, r, rad, ref1, ref2, ref3, ref4, ref5, t, t1, t2, u, u1, u2, u3, u4, v, v1, v2, v3, v4, x;
    a = getId('aR').value * PI / 2;
    b = a + getId('bR').value * (PI - 2 * a);
    r = getId('rR').value * PI / 2;
    t = getId('tR').value * TAN(a / 2) / 4;
    t1 = t * SIN(r);
    t2 = t * SIN(2 * Math.atan(TAN(r / 2) * SIN((b - a) / 2) / SIN((b + a) / 2)));
    getId('aL').innerHTML = (a * 180 / PI).toFixed(2);
    getId('bL').innerHTML = (b * 180 / PI).toFixed(2);
    getId('tL').innerHTML = t.toFixed(2);
    getId('rL').innerHTML = r.toFixed(2);
    f1 = makeSector(0, a);
    f2 = makeSector(a, b);
    f3 = makeSector(a + b, PI - a);
    f4 = makeSector(PI + b, PI - b);
    getId('l1').setAttribute('d', makeCycle(f1));
    getId('l2').setAttribute('d', makeCycle(f2));
    getId('l3').setAttribute('d', makeCycle(f3));
    getId('l4').setAttribute('d', makeCycle(f4));
    getId('u1').setAttribute('d', makeCycle(offsetCorner(f1, t)));
    getId('u2').setAttribute('d', makeCycle(offsetCorner(f2, t)));
    getId('u3').setAttribute('d', makeCycle(offsetCorner(f3, t)));
    getId('u4').setAttribute('d', makeCycle(offsetCorner(f4, t)));
    getId('s1').setAttribute('d', makeCycle(offsetCorner(f1, t1)));
    getId('s2').setAttribute('d', makeCycle(offsetCorner(f2, t1)));
    getId('s3').setAttribute('d', makeCycle(offsetCorner(f3, t1)));
    getId('s4').setAttribute('d', makeCycle(offsetCorner(f4, t1)));
    getId('t1').setAttribute('d', makeCycle(offsetCorner(f1, t2)));
    getId('t2').setAttribute('d', makeCycle(offsetCorner(f2, t2)));
    getId('t3').setAttribute('d', makeCycle(offsetCorner(f3, t2)));
    getId('t4').setAttribute('d', makeCycle(offsetCorner(f4, t2)));
    ref1 = (function() {
      var l, len, ref1, results;
      ref1 = [f1, f2, f3, f4];
      results = [];
      for (l = 0, len = ref1.length; l < len; l++) {
        f = ref1[l];
        results.push(unit(f[1]));
      }
      return results;
    })(), u1 = ref1[0], u2 = ref1[1], u3 = ref1[2], u4 = ref1[3];
    ref2 = (function() {
      var l, len, ref2, results;
      ref2 = [f1, f2, f3, f4];
      results = [];
      for (l = 0, len = ref2.length; l < len; l++) {
        f = ref2[l];
        results.push(dir(f[1], f[2]));
      }
      return results;
    })(), v1 = ref2[0], v2 = ref2[1], v3 = ref2[2], v4 = ref2[3];
    x = t1 / TAN(a / 2);
    p1 = plus(cyc(f1, -1), mul(v2, -t1));
    p2 = plus(p1, mul(u2, -x));
    p3 = plus(p2, mul(v2, t1));
    p4 = mul(u2, x);
    p5 = plus(p4, mul(v2, -t1));
    p6 = mul(u1, t1 / SIN(a));
    ps = [p1, p2, p3, p4, p5, p6].concat(f1.slice(1, -1));
    getId('a1').setAttribute('d', makeCycle(ps));
    p1 = plus(cyc(f2, -1), mul(u3, -x));
    p2 = plus(p1, mul(v3, -t2));
    p4 = mul(u3, x);
    p3 = plus(p4, mul(v3, -t2));
    p5 = mul(u2, x);
    p6 = plus(p5, mul(v2, t1));
    p8 = plus(f2[1], mul(u2, -x));
    p7 = plus(p8, mul(v2, t1));
    ps = [p1, p2, p3, p4, [0, 0], p5, p6, p7, p8].concat(f2.slice(1));
    getId('a2').setAttribute('d', makeCycle(ps));
    p1 = plus(cyc(f3, -1), mul(u4, -x));
    p2 = plus(p1, mul(v4, -t1));
    p6 = plus(mul(v3, t2), mul(u3, -MAX(0, t2 * TAN(b - PI / 2))));
    p4 = mul(u4, x);
    p3 = plus(p4, mul(v4, -t1));
    p5 = mul(u4, dot(p6, u4));
    p8 = mul(u3, x);
    p7 = plus(p8, mul(v3, t2));
    p9 = plus(f3[1], mul(u3, -x));
    p10 = plus(p9, mul(v3, t2));
    p11 = plus(f3[1], mul(v3, t2));
    ps = [p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11].concat(f3.slice(2));
    getId('a3').setAttribute('d', makeCycle(ps));
    p1 = mul(u1, t1 / SIN(a));
    p2 = mul(uAng((a + b - PI) / 2), t1 / SIN((PI - b + a) / 2));
    p4 = mul(u4, x);
    p3 = plus(p4, mul(v4, t1));
    p5 = mul(u4, 1 - x);
    p6 = plus(p5, mul(v4, t1));
    p7 = plus(f4[1], mul(v4, t1));
    ps = [p1, p2, p3, p4, p5, p6, p7].concat(f4.slice(1));
    getId('a4').setAttribute('d', makeCycle(ps));
    p2 = mul(u1, MAX(0, t2 / TAN(PI - b)));
    p1 = mul(u2, MAX(0, t2 / TAN(PI - b)) / COS(a));
    p3 = mul(u1, x);
    p4 = plus(p3, mul(v1, t2));
    p5 = plus(mul(f1[1], 1 - x), mul(v1, t2));
    p6 = plus(p5, mul(v1, -t2));
    ps = [p1, p2, p3, p4, p5, p6].concat(f1.slice(1));
    getId('b1').setAttribute('d', makeCycle(ps));
    getId('b2').setAttribute('d', makeCycle(f2));
    getId('b3').setAttribute('d', makeCycle(f3));
    p1 = plus(cyc(f4, -1), mul(v1, -t2));
    p2 = plus(p1, mul(u1, -x));
    p3 = plus(p2, mul(v1, t2));
    p4 = mul(u1, x);
    p5 = plus(p4, mul(v1, -t2));
    p6 = mul(u4, t2 / SIN(PI - b));
    ps = [p1, p2, p3, p4, p5, p6].concat(f4.slice(1, -1));
    getId('b4').setAttribute('d', makeCycle(ps));
    rad = t / 2 * 0.95;
    ref3 = (function() {
      var l, len, ref3, ref4, results;
      ref3 = [[u1, u2], [u2, u3], [u3, u4], [u4, u1]];
      results = [];
      for (l = 0, len = ref3.length; l < len; l++) {
        ref4 = ref3[l], u = ref4[0], v = ref4[1];
        results.push(mul(unit(plus(u, v)), (t1 + t) / SIN(ang(u, v) / 2)));
      }
      return results;
    })(), p1 = ref3[0], p2 = ref3[1], p3 = ref3[2], p4 = ref3[3];
    setAttrs(getId('c11'), {
      r: rad,
      cx: p1[0],
      cy: p1[1]
    });
    setAttrs(getId('c21'), {
      r: rad,
      cx: p2[0],
      cy: p2[1]
    });
    setAttrs(getId('c31'), {
      r: rad,
      cx: p3[0],
      cy: p3[1]
    });
    setAttrs(getId('c41'), {
      r: rad,
      cx: p4[0],
      cy: p4[1]
    });
    ref4 = (function() {
      var l, len, ref4, ref5, results;
      ref4 = [[u1, v1], [u2, v2], [u3, v3], [u4, v4]];
      results = [];
      for (l = 0, len = ref4.length; l < len; l++) {
        ref5 = ref4[l], u = ref5[0], v = ref5[1];
        results.push(plus(mul(v, t + t1), mul(u, 1 - t)));
      }
      return results;
    })(), p1 = ref4[0], p2 = ref4[1], p3 = ref4[2], p4 = ref4[3];
    setAttrs(getId('c12'), {
      r: rad,
      cx: p1[0],
      cy: p1[1]
    });
    setAttrs(getId('c22'), {
      r: rad,
      cx: p2[0],
      cy: p2[1]
    });
    setAttrs(getId('c32'), {
      r: rad,
      cx: p3[0],
      cy: p3[1]
    });
    setAttrs(getId('c42'), {
      r: rad,
      cx: p4[0],
      cy: p4[1]
    });
    ref5 = (function() {
      var l, len, ref5, ref6, results;
      ref5 = [[u1, v1], [u2, v2], [u3, v3], [u4, v4]];
      results = [];
      for (l = 0, len = ref5.length; l < len; l++) {
        ref6 = ref5[l], u = ref6[0], v = ref6[1];
        results.push(plus(mul(v, -t - t1), mul(u, 1 - t)));
      }
      return results;
    })(), p1 = ref5[0], p2 = ref5[1], p3 = ref5[2], p4 = ref5[3];
    setAttrs(getId('c13'), {
      r: rad,
      cx: p1[0],
      cy: p1[1]
    });
    setAttrs(getId('c23'), {
      r: rad,
      cx: p2[0],
      cy: p2[1]
    });
    setAttrs(getId('c33'), {
      r: rad,
      cx: p3[0],
      cy: p3[1]
    });
    setAttrs(getId('c43'), {
      r: rad,
      cx: p4[0],
      cy: p4[1]
    });
    getId('frontG').setAttribute('visibility', (showF ? 'visible' : 'hidden'));
    getId('backG').setAttribute('visibility', (showB ? 'visible' : 'hidden'));
    getId('sketchG').setAttribute('visibility', (showS ? 'visible' : 'hidden'));
    return getId('circleG').setAttribute('visibility', (showC ? 'visible' : 'hidden'));
  };

  window.onload = function() {
    var backG, circleG, frontG, sketchG, styles, svg;
    svg = getId('draw').appendChild(createSVG('svg', {
      id: 'svg',
      "class": 'svg',
      xmlns: SVGNS,
      width: 600,
      height: 600,
      viewBox: '-1.5 -1.5 3 3'
    }));
    styles = '.svg { background-color: white; } .circle { fill: #FFFFFF; } .blue { fill: #0000FF; fill-opacity: 0.3; } .red { fill: #FF0000; fill-opacity: 0.3; } .line { stroke-width: 0.01; stroke-linejoin: round; } .line.nofill { fill: none } .line.K { stroke: #000000; } .line.R { stroke: #FF0000; } .line.G { stroke: #00FF00; } .line.B { stroke: #0000FF; }';
    svg.appendChild(createXHTML('style', {
      type: 'text/css'
    })).innerHTML = styles;
    backG = svg.appendChild(createSVG('g', {
      id: 'backG'
    }));
    backG.appendChild(createSVG('path', {
      id: 'b1',
      "class": 'K line fill red'
    }));
    backG.appendChild(createSVG('path', {
      id: 'b2',
      "class": 'K line fill red'
    }));
    backG.appendChild(createSVG('path', {
      id: 'b3',
      "class": 'K line fill red'
    }));
    backG.appendChild(createSVG('path', {
      id: 'b4',
      "class": 'K line fill red'
    }));
    frontG = svg.appendChild(createSVG('g', {
      id: 'frontG'
    }));
    frontG.appendChild(createSVG('path', {
      id: 'a1',
      "class": 'K line fill blue'
    }));
    frontG.appendChild(createSVG('path', {
      id: 'a2',
      "class": 'K line fill blue'
    }));
    frontG.appendChild(createSVG('path', {
      id: 'a3',
      "class": 'K line fill blue'
    }));
    frontG.appendChild(createSVG('path', {
      id: 'a4',
      "class": 'K line fill blue'
    }));
    circleG = svg.appendChild(createSVG('g', {
      id: 'circleG'
    }));
    circleG.appendChild(createSVG('circle', {
      id: 'c11',
      "class": 'K line circle'
    }));
    circleG.appendChild(createSVG('circle', {
      id: 'c21',
      "class": 'K line circle'
    }));
    circleG.appendChild(createSVG('circle', {
      id: 'c31',
      "class": 'K line circle'
    }));
    circleG.appendChild(createSVG('circle', {
      id: 'c41',
      "class": 'K line circle'
    }));
    circleG.appendChild(createSVG('circle', {
      id: 'c12',
      "class": 'K line circle'
    }));
    circleG.appendChild(createSVG('circle', {
      id: 'c22',
      "class": 'K line circle'
    }));
    circleG.appendChild(createSVG('circle', {
      id: 'c32',
      "class": 'K line circle'
    }));
    circleG.appendChild(createSVG('circle', {
      id: 'c42',
      "class": 'K line circle'
    }));
    circleG.appendChild(createSVG('circle', {
      id: 'c13',
      "class": 'K line circle'
    }));
    circleG.appendChild(createSVG('circle', {
      id: 'c23',
      "class": 'K line circle'
    }));
    circleG.appendChild(createSVG('circle', {
      id: 'c33',
      "class": 'K line circle'
    }));
    circleG.appendChild(createSVG('circle', {
      id: 'c43',
      "class": 'K line circle'
    }));
    sketchG = svg.appendChild(createSVG('g', {
      id: 'sketchG'
    }));
    sketchG.appendChild(createSVG('path', {
      id: 's1',
      "class": 'R line nofill'
    }));
    sketchG.appendChild(createSVG('path', {
      id: 's2',
      "class": 'R line nofill'
    }));
    sketchG.appendChild(createSVG('path', {
      id: 's3',
      "class": 'R line nofill'
    }));
    sketchG.appendChild(createSVG('path', {
      id: 's4',
      "class": 'R line nofill'
    }));
    sketchG.appendChild(createSVG('path', {
      id: 't1',
      "class": 'B line nofill'
    }));
    sketchG.appendChild(createSVG('path', {
      id: 't2',
      "class": 'B line nofill'
    }));
    sketchG.appendChild(createSVG('path', {
      id: 't3',
      "class": 'B line nofill'
    }));
    sketchG.appendChild(createSVG('path', {
      id: 't4',
      "class": 'B line nofill'
    }));
    sketchG.appendChild(createSVG('path', {
      id: 'u1',
      "class": 'G line nofill'
    }));
    sketchG.appendChild(createSVG('path', {
      id: 'u2',
      "class": 'G line nofill'
    }));
    sketchG.appendChild(createSVG('path', {
      id: 'u3',
      "class": 'G line nofill'
    }));
    sketchG.appendChild(createSVG('path', {
      id: 'u4',
      "class": 'G line nofill'
    }));
    sketchG.appendChild(createSVG('path', {
      id: 'l1',
      "class": 'K line nofill'
    }));
    sketchG.appendChild(createSVG('path', {
      id: 'l2',
      "class": 'K line nofill'
    }));
    sketchG.appendChild(createSVG('path', {
      id: 'l3',
      "class": 'K line nofill'
    }));
    sketchG.appendChild(createSVG('path', {
      id: 'l4',
      "class": 'K line nofill'
    }));
    getId('aR').addEventListener('input', function() {
      return update();
    });
    getId('bR').addEventListener('input', function() {
      return update();
    });
    getId('rR').addEventListener('input', function() {
      return update();
    });
    getId('tR').addEventListener('input', function() {
      return update();
    });
    getId('front').addEventListener('click', function() {
      showF = !showF;
      return update();
    });
    getId('back').addEventListener('click', function() {
      showB = !showB;
      return update();
    });
    getId('sketch').addEventListener('click', function() {
      showS = !showS;
      return update();
    });
    getId('circle').addEventListener('click', function() {
      showC = !showC;
      return update();
    });
    return update();
  };

}).call(this);
