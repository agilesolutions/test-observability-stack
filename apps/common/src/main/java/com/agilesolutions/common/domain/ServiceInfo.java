package com.agilesolutions.common.domain;

import lombok.Builder;
import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "application.info")
@Data
@Builder
public class ServiceInfo {

    private String name;
    private String version;
    private String description;
    private boolean featureToggle;
}
