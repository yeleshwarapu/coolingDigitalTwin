function [w, h] = get_rad_dimensions(type)
    switch type
        case '1x120', w = 120; h = 140;
        case '2x120', w = 240; h = 140;
        case '3x120', w = 360; h = 140;
        case '1x140', w = 140; h = 160;
        case '2x140', w = 280; h = 160;
        case '3x140', w = 420; h = 160;
        otherwise, error('Invalid rad_type');
    end
end
