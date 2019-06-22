/*
Blending module. 

Doesn't actually blend shapes, but gives you a nice DSL to
handle stepping through different variables with different easing.

Then hulls between each of the steps to join them together.

Example 1:
blend(10) between([
    tween("z", 0, 10),
    tween("size", [1, 1, _e], [2, 2, _e])
]) t(tval("z")*Z) cube(tval("size"));    

You can specify easing as a fourth argument to tween. For vector tweened parameters, easing 
can be a single easing (used for all members of vector) or one per vector (in which case must be exactly the same length)

Example 2:
blend(10) between([
    tween("pos", [0, 0, 0], [10, 0 10], ["inQuad", "linear", "linear"]),
    tween("size", [1, 1, _e], [2, 2, _e], "linear")
]) t(tval("pos")) cube(tval("size"));    
*/

module blend(frames=10) {
    $bf=frames;
    children();
}

module between(tweens=[], debug=false) {
    for (i = [0 : 1 : len(tweens[0][1]) - 2]) {
        hull_if(!debug) {
            union() {
                $i=i;
                $tvals = [for (tween = tweens) [tween[0], tween[1][i]]];
                children();
            }
            union() {
                $i=i+1;
                $tvals = [for (tween = tweens) [tween[0], tween[1][i + 1]]];
                children();
            }
        }
    }
}

// a and b can be numbers or vectors. Must be same type & length
// easing can be single string or vector. If single string, used for all items.
function tween(name, a, b, easing) =
    let (steps = $bf - 1)

    type(a) == "vector" ? (
        let (diff = [for (z = zip(a, b)) z[1] - z[0]])
        let (_es = type(easing) == "vector" ? easing : repeat(easing, len(a)))

        [
            name,
            [for (i = [0 : 1 : steps]) 
                [for (j = [0:len(a)-1]) ease(_es[j], i, a[j], diff[j], steps)]
            ]
        ]
    ) : (
        let (diff = b - a)
        let (_es = type(easing) == "vector" ? easing[0] : easing)

        [
            name,
            [for (i = [0 : 1 : steps])
                ease(_es, i, a, diff, steps)
            ]
        ]
    );

function tval(name) = $tvals[search([name], $tvals)[0]][1];

