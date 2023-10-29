function setup() {
  createCanvas(640,640);
  frameRate(15);
}

let pixelSize = 6;
function draw() {
  // プログラムを実行してから経過した秒数
  let t = millis()/1000;

  // 2次方程式を解く関数。実数解でない要素はNaNとなる
  let solve = (a,b,c) => [
    (-b + sqrt(b**2 - 4*a*c)) / 2*a,
    (-b - sqrt(b**2 - 4*a*c)) / 2*a
  ];

  // ベクトルの演算の関数
  // 引数のsはスカラー、vとwは3次元ベクトル
  let mul = (s,v) => v.map(e => s*e);
  let add = (v,w) => v.map((e,i) => e + w[i]);
  let sub = (v,w) => add(v, mul(-1,w));
  let dot = (v,w) => v[0]*w[0] + v[1]*w[1] + v[2]*w[2];
  let norm = (v) => sqrt(v[0]**2 + v[1]**2 + v[2]**2);
  let normalize = (v) => mul(1/norm(v), v);

  // 投影面上の1点 [l,m] の明るさを0～1の範囲で求める関数
  let briFilm = (l,m) => {
    let briFloor = (x,z) => {
      if (abs(z) > 60) return 0;
      let checker = (x,z) => constrain(6*sin(x*PI/4)*cos(z*PI/4), 0, 1);
      return constrain(140*checker(x,z) / z**2, 0, 1);
    }

    // ピンホールから伸びる光線と球の交点swを求める
    // cは球の位置、rは球の半径
    let w = normalize([l, m, 1]);
    let c = [mouseX/60 - 5.5, 1, -mouseY/60 + 18];
    let r = 2;
    let s = min(solve(dot(w,w), 2*dot(w,mul(-1,c)), dot(c,c)-r**2));
    let sw = mul(s,w);
    
    if (isNaN(s)) {
      // 球との交点がない場合、前章と同じく床との交点をとる
      let p = [3, -5].map(h => [l*h/m, h, h/m]);
      p = p.reduce((a,b) => a[2]>b[2] ? a : b);
      return briFloor(p[0], p[2]);
    }

    // 球から反射する光線 b を求める
    let n = normalize(sub(sw,c));
    let b = add(sw, mul(dot(mul(-2,sw),n), n));
    
    // 光線と床の交点 v = sw+ub を求める
    // uの候補
    let u = [0,1].map(i => {
      let n = [0, [1, -1][i], 0];
      let h = [3, 5][i];
      return (h - dot(n,sw)) / dot(n,b);
    });
    // uを正の解に絞る
    u = u.filter(e => e>0)[0];
    let v = add(sw, mul(u,b));
    return briFloor(v[0], v[2]);
  };

  // 描画
  background(0);
  noStroke();

  let p = pixelSize;
  for(let y=0; y<height; y+=p) {
    for(let x=0; x<width; x+=p) {
      let l = x/width - 1/2;
      let m = y/height - 1/2;
      fill(255 * briFilm(l,m));
      rect(x, y, p, p);
    }
  }
}

function keyPressed() {
  // q,wキーで画質を調整
  if (keyCode === 81) pixelSize--;
  if (keyCode === 87) pixelSize++;
  pixelSize = constrain(pixelSize, 3, 8);
}