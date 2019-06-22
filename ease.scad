
function easeLinear(t, b, c, d) = c*t/d + b;

function easeInQuad(t, b, c, d) = let(i=t/d) c*i*i + b;
function easeOutQuad(t, b, c, d) = let(i=t/d) -c*i*(i-2) + b;
function easeInOutQuad(t, b, c, d) = 
    let(i=t/(d/2))
    i < 1 ?
        c/2*i*i + b :
		let(i2=i-1) -c/2 * (i2*(i2-2) - 1) + b;
function easeInCubic(t, b, c, d) = let(i=t/d) c*i*i*i + b;
function easeOutCubic(t, b, c, d) = let(i=t/d-1) c*(i*i*i + 1) + b;
function easeInOutCubic(t, b, c, d) =
    let(i=t/(d/2))
    i < 1 ?
        c/2*i*i*i + b :
        let(i2=i-2) c/2 * (i2*i2*i2 + 2) + b;
function easeInQuart(t, b, c, d) = let(i=t/d) c*i*i*i*i + b;
function easeOutQuart(t, b, c, d) = let(i=t/d-1) -c*(i*i*i*i - 1) + b; 
function easeInOutQuart(t, b, c, d) =
    let(i=t/(d/2))
    i < 1 ?
        c/2*i*i*i*i + b :
        let(i2=i-2) -c/2 * (i2*i2*i2*i2 - 2) + b;
function easeInQuint(t, b, c, d) = let(i=t/d) c*i*i*i*i*i + b;
function easeOutQuint(t, b, c, d) = let(i=t/d-1) c*(i*i*i*i*i + 1) + b;
function easeInOutQuint(t, b, c, d) =
    let(i=t/(d/2))
    i < 1 ?
        c/2*i*i*i*i*i + b :
        let(i2=i-2) c/2 * (i2*i2*i2*i2*i2 + 2) + b;

function easeInSine(t, b, c, d) = -c * cos(t/d * 90) + c + b;
function easeOutSine(t, b, c, d) = c * sin(t/d * 90) + b;
function easeInOutSine(t, b, c, d) = -c/2 * (cos(180*t/d) - 1) + b;

function easeInExpo(t, b, c, d) = (t==0) ? b : c * pow(2, 10 * (t/d - 1)) + b;
function easeOutExpo(t, b, c, d) = (t==d) ? b+c : c * (-pow(2, -10 * t/d) + 1) + b;
function easeInOutExpo(t, b, c, d) =
    let(i=t/(d/2))
    (t==0) ? b :
    (t==d) ? b+c :
    (i < 1) ? c/2 * pow(2, 10 * (t - 1)) + b:
    let(i2=i-1) c/2 * (-pow(2, -10 * i2) + 2) + b;

function easeInCirc(t, b, c, d) = let(i=t/d) -c * (sqrt(1 - i*i) - 1) + b;
function easeOutCirc(t, b, c, d) = let(i=t/d-1) c * sqrt(1 - i*i) + b;
function easeInOutCirc(t, b, c, d) =
    let(i=t/(d/2))
    i < 1 ?
        -c/2 * (sqrt(1 - i*i) - 1) + b :
		let(i2=i-2) c/2 * (sqrt(1 - i2*i2) + 1) + b;

function ease(mode, t, b, c, d) =
  mode == "inQuad" ? easeInQuad(t, b, c, d) :
  mode == "outQuad" ? easeOutQuad(t, b, c, d) :
  mode == "inOutQuad" ? easeInOutQuad(t, b, c, d) :
  mode == "inCubic" ? easeInCubic(t, b, c, d) :
  mode == "outCubic" ? easeOutCubic(t, b, c, d) :
  mode == "inOutCubic" ? easeInOutCubic(t, b, c, d) :
  mode == "inQuart" ? easeInQuart(t, b, c, d) :
  mode == "outQuart" ? easeOutQuart(t, b, c, d) :
  mode == "inOutQuart" ? easeInOutQuart(t, b, c, d) :
  mode == "inQuint" ? easeInQuint(t, b, c, d) :
  mode == "outQuint" ? easeOutQuint(t, b, c, d) :
  mode == "inOutQuint" ? easeInOutQuint(t, b, c, d) :
  mode == "inSine" ? easeInSine(t, b, c, d) :
  mode == "outSine" ? easeOutSine(t, b, c, d) :
  mode == "inOutSine" ? easeInOutSine(t, b, c, d) :
  mode == "inExpo" ? easeInExpo(t, b, c, d) :
  mode == "outExpo" ? easeOutExpo(t, b, c, d) :
  mode == "inOutExpo" ? easeInOutExpo(t, b, c, d) :
  mode == "inCirc" ? easeInCirc(t, b, c, d) :
  mode == "outCirc" ? easeOutCirc(t, b, c, d) :
  mode == "inOutCirc" ? easeInOutCirc(t, b, c, d) :
  easeLinear(t, b, c, d);