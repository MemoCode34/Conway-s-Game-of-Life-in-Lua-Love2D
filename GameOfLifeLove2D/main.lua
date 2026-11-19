CELL_SIZE = 20
COLS = 40
ROWS = 30
ENV = {}

local paused = false
local placing = false
local placing_cell_pos_x, placing_cell_pos_y


function love.load()
    love.window.setTitle("Game Of Life")
    love.window.setMode(COLS * CELL_SIZE, ROWS * CELL_SIZE)
    --local was_dead = false
    for y = 1, ROWS do 
        for x = 1, COLS do
            local grid_pos = (y - 1) * COLS + x
            ENV[grid_pos] = Cell:new(true)
            --was_dead = not was_dead
        end
    end
end

function love.update(dt)
    mouse_pos_x, mouse_pos_y = love.mouse.getPosition()
    for i = 1, COLS, 1 do 
        if mouse_pos_x <= COLS * i or mouse_pos_x >= COLS * (i - 1) then 
            placing_cell_pos_x = COLS * (i - 1)
        end
        if mouse_pos_y <= ROWS * i or mouse_pos_y >= ROWS * (i - 1) then 
            placing_cell_pos_y = ROWS * (i - 1)
        end
    end
    next_states = {}
    for y = 1, ROWS do 
        for x = 1, COLS do 
            local grid_pos = (y - 1) * COLS + x
            next_states[grid_pos] = ENV[grid_pos]:CalculateStatus(x, y)
        end
    end

    for i, cell in ipairs(ENV) do
        if not paused then
            cell.is_dead = next_states[i]
        end
    end

    love.timer.sleep(0.1)
end

function love.draw()
    love.graphics.clear(0.1, 0.1, 0.1)
    for i, cell in ipairs(ENV) do 
        if not cell.is_dead then 
            local col = (i - 1) % COLS
            local row = math.floor((i - 1) / COLS)
            love.graphics.setColor(0.2, 0.8, 0.3)
            if placing then 
                --drawRect(placing_cell_pos_x, placing_cell_pos_y)
                drawRect(col * CELL_SIZE, row * CELL_SIZE)
            end
        end
    end
    if paused then love.graphics.print("Paused", love.graphics.getWidth()/2 - 20) end
    love.graphics.print("[Pause:Space][Place/Delete Cells: LMB/RMB)][Delete All: Q]", love.graphics.getWidth()/2 - 200, love.graphics.getHeight() - 20)
end

function love.keypressed(key)
    if key == "space" then 
        paused = not paused
    end
    if key == "q"  and paused then 
        for idx, _ in ipairs(next_states) do 
            ENV[idx].is_dead = true
        end
    end
end

function love.mousepressed(x, y, button)
    if button == 1 and paused then
        placing = true
        local col = math.floor(x / CELL_SIZE) + 1
        local row = math.floor(y / CELL_SIZE) + 1
        if col >= 1 and col <= COLS and row >= 1 and row <= ROWS then
            local idx = (row - 1) * COLS + col
            ENV[idx].is_dead = false
        end
    end
    if button == 2 and paused then 
        local col = math.floor(x / CELL_SIZE) + 1
        local row = math.floor(y / CELL_SIZE) + 1
        if col >= 1 and col <= COLS and row >= 1 and row <= ROWS then
            local idx = (row - 1) * COLS + col
            ENV[idx].is_dead = true
        end
    end
end

function drawRect(pos_x, pos_y)
    love.graphics.rectangle("fill", pos_x, pos_y, CELL_SIZE - 1, CELL_SIZE - 1)
end


Cell = {}
Cell.__index = Cell

function Cell:new(is_dead)
    local obj = {is_dead = is_dead}
    setmetatable(obj, self)
    return obj
end

function Cell:CalculateStatus(x, y)
   local neighbor_count = 0
    for dy = -1, 1 do
        for dx = -1, 1 do
            if dx ~= 0 or dy ~= 0 then
                local nx = x + dx
                local ny = y + dy
                if nx >= 1 and nx <= COLS and ny >= 1 and ny <= ROWS then
                    local n_pos = (ny - 1) * COLS + nx
                    if ENV[n_pos] and not ENV[n_pos].is_dead then
                        neighbor_count = neighbor_count + 1
                    end
                end
            end
        end
    end

    if self.is_dead then
        if neighbor_count == 3 then
            return false 
        else
            return true  
        end
    else
        if neighbor_count == 2 or neighbor_count == 3 then
            return false 
        else
            return true  
        end
    end
end