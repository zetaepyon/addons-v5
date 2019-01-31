local math = require('math')
local string = require('string')
local ui = require('ui')

--local pos = { x = 150, y = 60}
local config_label = '15px Roboto bold stroke:"1px black"'
local sample_text = 'Sample サンプル 🐱‍👤💯'
local sample_font = 'Arial'
local sample_size = 50
local sample_color = ui.color.green
local sample_stroke_color = ui.color.rgb(255,0,0,196)
local sample_stroke_size = 5
local radio_style = 0
local bold_checked = false
local italic_checked = false
local underline_checked = false
local strikethrough_checked = false
local styles = {[0] = '', [1] = ' condensed', [2] = ' semi_condensed'}
local bold = {[true] = ' bold', [false] = ''}
local italic = {[true] = ' italic', [false] = ''}
local underline = {[true] = ' underline', [false] = ''}
local strikethrough = {[true] = ' strikethrough', [false] = ''}
local window_color = ui.color.black
local color_mode = 0
local radio_mode = 1
local window_mode = 'chromeless'

local config_state = {
    title = 'Demo UI Configuration',
    style = 'normal',
    x = 100,
    y = 100,
    width = 310,
    height = 405,
    resizable = false,
    moveable = false,
}
local config_closed

local demo_state = {
    title = 'Demo Text Window',
    style = window_mode,
    color = window_color,
    x = 500,
    y = 100,
    width = 500,
    height = 100,
}
local demo_closed

ui.display(function()

    local x1, x2, y = 5, 105, 5

    config_state, config_closed = ui.window('config_window', config_state, function()
        ui.location(x1, y)
        ui.text(string.format('[Sample Text]{%s}', config_label))
        ui.location(x2, y)
        ui.size(200, 20)
        sample_text = ui.edit('Sample', sample_text)

        y = y + 25
        ui.location(x1, y)
        ui.text(string.format('[Typeface]{%s}', config_label))
        ui.location(x2, y)
        ui.size(200, 20)
        sample_font = ui.edit('Typeface', sample_font)

        y = y + 25
        ui.location(x1, y)
        ui.text(string.format('[Text Size]{%s}', config_label))
        ui.location(x2, y)
        ui.size(150, 20)
        sample_size = math.floor(ui.slider('slider1', sample_size, {min = 8, max = 96}) + 0.5)

        y = y + 25
        ui.location(x1, y)
        ui.text(string.format('[Stroke Size]{%s}', config_label))
        ui.location(x2, y)
        ui.size(100, 20)
        sample_stroke_size = math.floor(ui.slider('slider2', sample_stroke_size, {min = 0, max = 10}))
        
        y = y + 25
        ui.location(x1, y)
        ui.text(string.format('[Text Style]{%s}', config_label))
        y = y + 25
        ui.location(x1, y)
        if ui.radio('radio1', 'Normal', radio_style == 0) then
            radio_style = 0
        end
        ui.location(x2 - 25, y)        
        if ui.radio('radio3', 'Semi-Condensed', radio_style == 2) then
            radio_style = 2
        end
        ui.location(x2 + 100, y)
        if ui.radio('radio2', 'Condensed', radio_style == 1) then
            radio_style = 1
        end

        y = y + 25
        ui.location(x1, y)
        if ui.check('bold_check', 'Bold', bold_checked) then
            bold_checked = not bold_checked
        end
        ui.location(x2 - 45, y)
        if ui.check('italic_check', 'Italic', italic_checked) then
            italic_checked = not italic_checked
        end
        ui.location(x2 + 15, y)
        if ui.check('underline_check', 'Underline', underline_checked) then
            underline_checked = not underline_checked
        end
        ui.location(x2 + 100, y)
        if ui.check('strikethrough_check', 'Strikethrough', strikethrough_checked) then
            strikethrough_checked = not strikethrough_checked
        end

        y = y + 25
        ui.location(x1, y)
        ui.text(string.format('[Window Style]{%s}', config_label))
        y = y + 25
        ui.location(x1, y)
        if ui.radio('moderadio1', 'Normal', radio_mode == 0) then
            radio_mode = 0
            demo_state.style = 'normal'
        end
        ui.location(x2, y)
        if ui.radio('moderadio2', 'Chromeless', radio_mode == 1) then 
            radio_mode = 1
            demo_state.style = 'chromeless' 
        end
        ui.location(x2 + 100, y)
        if ui.radio('moderadio3', 'Layout', radio_mode == 2) then 
            radio_mode = 2
            demo_state.style = 'layout' 
        end

        y = y + 25
        ui.location(x1, y)
        ui.text(string.format('[Color Configuration]{%s}', config_label))
        y = y + 25
        ui.location(x2, y)
        if color_mode == 0 then
            sample_color = ui.color_picker('Color', sample_color)
        elseif color_mode == 1 then
            window_color = ui.color_picker('Color2', window_color)
        elseif color_mode == 2 then
            sample_stroke_color = ui.color_picker('Color3', sample_stroke_color)
        end
        ui.draw.rectangle(x1, y, 20, 15, sample_color)
        ui.location(x1 + 25, y)
        if ui.radio('colorradio1', 'Text', color_mode == 0) then
            color_mode = 0
        end
        y = y + 25
        ui.draw.rectangle(x1, y, 20, 15, window_color)
        ui.location(x1 + 25, y)
        if ui.radio('colorradio2', 'Window', color_mode == 1) then
            color_mode = 1
        end
        y = y + 25
        ui.draw.rectangle(x1, y, 20, 15, sample_stroke_color)
        ui.location(x1 + 25, y)
        if ui.radio('colorradio3', 'Stroke', color_mode == 2) then
            color_mode = 2
        end

        demo_state.color = window_color
    end)

    demo_state, demo_closed = ui.window('demo_window', demo_state, function()
        ui.location(5,5)
        ui.text(string.format('[%s]{size:%spx color:%s typeface:"%s" stroke:"%spx %s"%s%s%s%s}', sample_text, tostring(sample_size), ui.color.tohex(sample_color), sample_font, tostring(sample_stroke_size), ui.color.tohex(sample_stroke_color), styles[radio_style], bold[bold_checked], italic[italic_checked], underline[underline_checked], strikethrough[strikethrough_checked]))
    end)

end)