# using Pkg
# Pkg.add("Images")
using Images
# define a modulo function that correctly handles negative numbers
function modulo(value, m)
    if (value < 0)
        return modulo(value + m, m)
    end

    value % m
end

# wrapper to index an array in wrapping fashion
function wrapGet(array, index)
    # index gets shifted -1 before modulo, because julia works with 1 based indexes
    newIndex = modulo(index-1, length(array))+1
    array[newIndex]
end

# start configuration is row of falses, with a true placed in the middle
function firstRow(length)
    mid = ceil(length/2)
    1:length .|> 
        (index) -> if (index == mid)
                true
            else
                false
            end
end

# performs the rule110 on 3 values
function rule110(input)
    # rules can be shortened to this expression, full ruleset here:
    # https://en.wikipedia.org/wiki/Rule_110
    sum(input) == 2 ||
    (!input[1] && (input[2] ^ input[3]))
end

function nextRow(previous)
    # generate an array 3-tuples that can be used to individually calculate a single cell
    # based of on the previous array
    function generateCells()
        getField(i)=wrapGet(previous, i)
        1:length(previous) .|> (i) -> ([i-1, i, i+1] .|> getField)
    end

    generateCells() .|> rule110
end

function generateRuleset(width, height)
    rows = [firstRow(width)]
    for i in 2:height
        next = nextRow(last(rows))
        push!(rows, next)
    end

    rows
end

function mapImg(input)
    # paint true cells as black, false ones as white
    color(b) = b ? 0.0 : 1.0

    tmpImg = input .|> (row) -> (row .|> color)

    # this is ugly, basically I just want to convert the tmpImg of type (Array{Array{Float64, 1}, 1})
    # to Array{Float64, 2}
    height = length(tmpImg)
    width = length(first(tmpImg))
    output = zeros(height, width)
    for y in 1:height
        for x in 1:width
            output[y, x] = tmpImg[y][x]
        end
    end

    output
end


function saveImage(filename :: String, input)
    img = mapImg(input)
    Images.save(filename, img)
end

# first, create a 21 by 21*3 version

saveImage("21x63.png", generateRuleset(21,63))


# let's go bonkers and create a huge 999x999 version!

saveImage("999x999.png", generateRuleset(999, 999))