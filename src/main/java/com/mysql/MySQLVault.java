package com.mysql;

import java.util.List;

import javax.annotation.PostConstruct;
import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceBuilder;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;
import org.springframework.jdbc.core.JdbcTemplate;

@SpringBootApplication
public class MySQLVault {

	public static void main(String[] args) {
		SpringApplication.run(MySQLVault.class, args);
	}

	@Bean
	@ConfigurationProperties(prefix = "spring.datasource")
	@Primary
	public DataSource dataSource() {
		return DataSourceBuilder.create().build();
	}

	@Autowired
	DataSource dataSource;

	@PostConstruct
	private void postConstruct() throws Exception {

		JdbcTemplate jdbcTemplate;
		jdbcTemplate = new JdbcTemplate(dataSource);

		String sqlString = "SELECT CURRENT_USER();";

		List<String> userID = jdbcTemplate.queryForList(sqlString, String.class);
		System.out.println("##################################################");
		System.out.println("Connection successful for User: " + userID.get(0));
		System.out.println("##################################################");

	}
}