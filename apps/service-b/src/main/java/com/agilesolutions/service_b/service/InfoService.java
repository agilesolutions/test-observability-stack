package com.agilesolutions.service_b.service;

import com.agilesolutions.common.domain.ServiceInfo;
import io.micrometer.observation.annotation.Observed;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.OffsetDateTime;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class InfoService {

    @Observed(name = "getInfo", contextualName = "Get service info", lowCardinalityKeyValues = {"service", "service-b"})
    public Optional<ServiceInfo> getInfo(String name) {

        log.info("Fetching service info for name: {}", name);

        return Optional.of(ServiceInfo.builder()
                .featureToggle(false)
                .description("test description")
                .version("1.0")
                .name("test name")
                .build());
    }


}
