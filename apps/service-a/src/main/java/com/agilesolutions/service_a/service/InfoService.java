package com.agilesolutions.service_a.service;

import com.agilesolutions.common.domain.ServiceInfo;
import lombok.AllArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

@Service
@Log4j2
@AllArgsConstructor
public class InfoService {

    private final RestClient restClient;

    public ServiceInfo getExternalInfo() {
        String url = "http://service-b/api/service-b/info";
        log.info("Fetching external info from URL: {}", url);
        return this.restClient.get()
                .uri(url)
                .accept(MediaType.APPLICATION_JSON)
                .retrieve()
                .body(ServiceInfo.class);
    }



}
