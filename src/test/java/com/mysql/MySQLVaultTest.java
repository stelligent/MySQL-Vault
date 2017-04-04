package com.mysql;

import java.util.List;

import javax.sql.DataSource;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.junit4.SpringRunner;

import static org.assertj.core.api.Assertions.assertThat;

@RunWith(SpringRunner.class)
@SpringBootTest
public class MySQLVaultTest {

	@Autowired
	DataSource dataSource;

	@Test
	public void shouldConnectToMySql() throws Exception {

		JdbcTemplate jdbcTemplate;
		jdbcTemplate = new JdbcTemplate(dataSource);

		String sqlString = "SELECT CURRENT_USER();";

		List<String> userID = jdbcTemplate.queryForList(sqlString, String.class);
		System.out.println("Connection successful for User: " + userID.get(0));
		assertThat(userID.get(0)).isNotEmpty();
	}

}
