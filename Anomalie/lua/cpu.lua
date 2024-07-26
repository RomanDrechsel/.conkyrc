function getCpuTemp()
    if Sensors and Sensors.Json then
        local temp = Sensors.Json["coretemp-isa-0000"]["Package id 0"]["temp1_input"];
        if temp then
            return toInt(temp) .. "°C"
        end
    end
    return ""
end
