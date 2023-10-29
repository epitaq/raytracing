class Image
    Pixcel = Struct.new(:r, :g, :b)
    def initialize(x, y)
        @img = Array.new(y) do
            Array.new(x) do Pixcel.new(255, 255, 255) end
        end
        @x, @y = x, y
    end
    def write(name)
        open(name, "wb") do |f|
            # f.puts("P6\n300 200\n255")
            f.printf("P6\n%d %d\n255\n", @x, @y)
            @img.each do |a|
                a.each do |p| f.write(p.to_a.pack("ccc")) end
            end
        end
    end
    def pset(x, y, r, g, b)
        if 0 <= x && x < @x && 0 <= y && y < @y
            @img[y][x].r = r; 
            @img[y][x].g = g; 
            @img[y][x].b = b; 
        else
            printf("out of range %d %d", x, y)
        end
    end
end

