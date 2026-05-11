package todo_springboot.service;

import com.baomidou.mybatisplus.extension.service.IService;
import todo_springboot.dto.SensorReportPayload;
import todo_springboot.entity.DeviceData;

import java.util.List;

public interface DeviceDataService extends IService<DeviceData> {

    DeviceData saveReport(SensorReportPayload payload);

    List<DeviceData> listHistory(String deviceId, int limit);
}
