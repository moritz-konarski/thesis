

w = 1_000
n = 1_000_000

data = rand(n)

p2 = zeros(w)

l_by_n_segments = n ÷ w

function a()::Vector{Float64}
    p1 = zeros(w)
    for i in 1:w
        sum = 0.0
        for j in (l_by_n_segments*(i-1)+1):(l_by_n_segments*i)
            sum += data[j]
        end
        p1[i] = w / n * sum
    end
    return p1
end

function b()::Vector{Float64}
    p2 = zeros(w)
    for i in 1:w
        p2[i] = sum(data[(l_by_n_segments*(i-1)+1):(l_by_n_segments*i)])
    end

    # p2 = [sum(data[(l_by_n_segments*(i.-1).+1):(l_by_n_segments*i)]) for i in 1:w]

    return (w / n) * p2
end

for _ in 1:10
    @time a()
end

for _ in 1:10
    @time b()
end

a() ≈ b()