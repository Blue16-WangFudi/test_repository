package com.example.springbootapp.todo;

import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.options;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

@SpringBootTest
@AutoConfigureMockMvc
class TodoControllerTests {
	@Autowired
	private MockMvc mockMvc;

	@Autowired
	private TodoService todoService;

	@BeforeEach
	void clearTodos() {
		todoService.clear();
	}

	@Test
	void createsListsUpdatesAndDeletesTodos() throws Exception {
		MvcResult createResult = mockMvc.perform(post("/api/todos")
						.contentType(MediaType.APPLICATION_JSON)
						.content("{\"title\":\"Write controller test\"}"))
				.andExpect(status().isCreated())
				.andExpect(jsonPath("$.title").value("Write controller test"))
				.andExpect(jsonPath("$.completed").value(false))
				.andReturn();

		String id = createResult.getResponse().getContentAsString()
				.replaceFirst(".*\"id\":\"([^\"]+)\".*", "$1");

		mockMvc.perform(put("/api/todos/{id}", id)
						.contentType(MediaType.APPLICATION_JSON)
						.content("{\"completed\":true,\"title\":\"Write API test\"}"))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.title").value("Write API test"))
				.andExpect(jsonPath("$.completed").value(true));

		mockMvc.perform(get("/api/todos").param("filter", "completed"))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.todos", hasSize(1)))
				.andExpect(jsonPath("$.stats.total").value(1))
				.andExpect(jsonPath("$.stats.completed").value(1));

		mockMvc.perform(delete("/api/todos/{id}", id))
				.andExpect(status().isNoContent());

		mockMvc.perform(get("/api/todos"))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.todos", hasSize(0)));
	}

	@Test
	void returnsErrorsForInvalidInputAndUnknownId() throws Exception {
		mockMvc.perform(post("/api/todos")
						.contentType(MediaType.APPLICATION_JSON)
						.content("{\"title\":\" \"}"))
				.andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.error").value("Todo title is required"));

		mockMvc.perform(put("/api/todos/missing")
						.contentType(MediaType.APPLICATION_JSON)
						.content("{\"completed\":true}"))
				.andExpect(status().isNotFound());

		mockMvc.perform(delete("/api/todos/missing"))
				.andExpect(status().isNotFound());
	}

	@Test
	void allowsFlutterWebCorsRequestsFromLocalhostDynamicPorts() throws Exception {
		mockMvc.perform(get("/api/todos")
						.header("Origin", "http://localhost:58214"))
				.andExpect(status().isOk())
				.andExpect(header().string("Access-Control-Allow-Origin", "http://localhost:58214"));

		mockMvc.perform(options("/api/todos")
						.header("Origin", "http://localhost:58214")
						.header("Access-Control-Request-Method", "POST")
						.header("Access-Control-Request-Headers", "content-type"))
				.andExpect(status().isOk())
				.andExpect(header().string("Access-Control-Allow-Origin", "http://localhost:58214"))
				.andExpect(header().string("Access-Control-Allow-Methods", "GET,POST,PUT,DELETE,OPTIONS"));
	}
}
