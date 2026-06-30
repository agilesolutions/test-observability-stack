package com.agilesolutions.service_b.service;

import com.agilesolutions.common.domain.ServiceInfo;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.OffsetDateTime;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class InfoService {

    public Optional<ServiceInfo> getInfo(String name) {
        return Optional.of(ServiceInfo.builder()
                .featureToggle(false)
                .description("test description")
                .version("1.0")
                .name("test name")
                .build());
    }


}
