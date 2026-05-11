CREATE TABLE IF NOT EXISTS `device_data` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `device_id` VARCHAR(64) NOT NULL COMMENT '设备ID',
  `temperature` DECIMAL(10, 2) DEFAULT NULL COMMENT '温度',
  `humidity` DECIMAL(10, 2) DEFAULT NULL COMMENT '湿度',
  `report_time` DATETIME NOT NULL COMMENT '上报时间',
  PRIMARY KEY (`id`),
  KEY `idx_device_report_time` (`device_id`, `report_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='设备传感器上报数据表';
