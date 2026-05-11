package todo_springboot.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import todo_springboot.dto.SensorReportPayload;
import todo_springboot.entity.DeviceData;
import todo_springboot.mapper.DeviceDataMapper;
import todo_springboot.service.DeviceDataService;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class DeviceDataServiceImpl extends ServiceImpl<DeviceDataMapper, DeviceData> implements DeviceDataService {

    @Override
    public DeviceData saveReport(SensorReportPayload payload) {
        DeviceData data = new DeviceData();
        data.setDeviceId(payload.getDeviceId());
        data.setTemperature(payload.getTemperature());
        data.setHumidity(payload.getHumidity());
        data.setReportTime(payload.getReportTime() == null ? LocalDateTime.now() : payload.getReportTime());
        save(data);
        return data;
    }

    @Override
    public List<DeviceData> listHistory(String deviceId, int limit) {
        int safeLimit = Math.max(1, Math.min(limit, 500));
        return lambdaQuery()
                .eq(StringUtils.hasText(deviceId), DeviceData::getDeviceId, deviceId)
                .orderByDesc(DeviceData::getReportTime)
                .last("LIMIT " + safeLimit)
                .list();
    }
}
