require './image.rb'

def draw()
  # 2次方程式を解く関数。実数解でない要素はNaNとなる
  def solve(a, b, c)
    if (b**2 - 4*a*c) < 0
      return  Float::NAN
    end
    return [
      (-b + Math.sqrt(b**2 - 4*a*c)) / (2*a).to_f,
      (-b - Math.sqrt(b**2 - 4*a*c)) / (2*a).to_f
    ]
  end

  # ベクトルの演算の関数
  # 引数のsはスカラー、vとwは3次元ベクトル
  def mul(s, v)
    return v.map{|i| i*s}
  end
  def add(v, w)
    return [v, w].transpose.map{|a| a.inject(:+) }
  end
  def sub(v, w)
    return add(v, mul(-1,w))
  end
  def dot(v,w)
    return v[0]*w[0] + v[1]*w[1] + v[2]*w[2]
  end
  def norm(v)
    return Math.sqrt(v[0]**2 + v[1]**2 + v[2]**2)
  end
  def normalize(v)
    return mul(1.to_f/norm(v), v)
  end

  # JSにしかない便利なやつ
  def constrain(n, low, high)
    if n < low then return low
    elsif n > high then return high
    else return n 
    end
  end

  # 投影面上の1点 [l,m] の明るさを0～1の範囲で求める関数
  def briFilm(l, m)
    def briFloor(x, z)
      if z.abs > 60 then 
        # puts('zが大きいよ!!')
        return 0 
      end
      def checker(x, z)
        return constrain(6*Math.sin(x*Math::PI/4)*Math.cos(z*Math::PI/4), 0, 1)
      end
      # return constrain(checker(x,z).to_f , 0, 1)
      return constrain(140*checker(x,z).to_f / z**2, 0, 1)
    end
    
    # ピンホールから伸びる光線と球の交点swを求める
    # cは球の位置、rは球の半径
    w = normalize([l, m, 1])
    c = [0, 1, 10]
    r = 2
    # puts(dot(w,w), 2*dot(w,mul(-1,c)), dot(c,c)-r**2)
    # puts('s',solve(dot(w,w), 2*dot(w,mul(-1,c)), dot(c,c)-r**2))
    s = solve(dot(w,w), 2*dot(w,mul(-1,c)), dot(c,c)-r**2)
    # 球との交点がない場合、床との交点をとる
    if [s] == [Float::NAN]
      # puts('球との交点がない')
      p = [3, -5].map{|h| [l*h/m.to_f, h, h/m.to_f]}
      p = p.reduce{|a,b| a[2]>b[2] ? a : b}
      return briFloor(p[0], p[2])
    else
      s = (solve(dot(w,w), 2*dot(w,mul(-1,c)), dot(c,c)-r**2)).min
    end
    sw = mul(s, w)

    # 球から反射する光線 b を求める
    n = normalize(sub(sw, c))
    # puts('n : ',n)
    b = add(sw, mul(dot(mul(-2, sw), n), n))

    # 光線と床の交点 v = sw+ub を求める
    # uの候補
    # TODO 怪しい
    # puts("sw, b", sw, b)
    u = [0, 1].map do |i|
      n = [0, [1, -1][i], 0]
      h = [3, 5][i];
      (h - dot(n,sw)) / dot(n,b).to_f
    end
    # uを正の解に絞る
    u = u.filter{|e| e>0}[0]
    # puts('u: ',u)
    v = add(sw, mul(u,b))
    # puts('v: ',v)
    # puts('briFloor: ',briFloor(v[0], v[2]))
    return briFloor(v[0], v[2])
  end
# vが同じところを指してる可能性
# 少数の丸め込みで中間で別れてる可能性
# 77l以降からおかしいぽい
# sのmin max いじっても変わらないのはおかしい
# bの値は半分同じ bが怪しい

  # 描画
  size = 3840
  img = Image.new(size, size)
  size.times do |y|
    size.times do |x|
      # puts(x.to_f / size)
      l = x.to_f / size - 0.49
      m = y.to_f / size - 0.49
      color = (255.0*briFilm(l, m))
      # puts('briFilm: ',briFilm(l, m))
      # puts('color: ', color)
      color.to_i
      img.pset(x, y, color,color,color)
    end
  end
  puts('書き込み')
  img.write('test12.ppm')
end


draw()

