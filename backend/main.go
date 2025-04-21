package main

import (
	"net/http"
	"strconv"

	"backend/models"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

var tasks = []models.Task{
	{ID: 1, Title: "First Task", Description: "Learn Flutter", Status: "todo"},
	{ID: 2, Title: "Second Task", Description: "Setup Go API", Status: "doing"},
}

// Auto increment ID untuk task baru
var nextID = 3

func main() {
	router := gin.Default()

	// Allow CORS (for Flutter Web)
	router.Use(cors.Default())

	// Routes
	router.GET("/tasks", getTasks)
	router.POST("/tasks", createTask)
	router.PATCH("/tasks/:id", updateTask)
	router.DELETE("/tasks/:id", deleteTask)

	router.Run(":8080")
}

// GET /tasks
func getTasks(c *gin.Context) {
	c.JSON(http.StatusOK, tasks)
}

// POST /tasks
func createTask(c *gin.Context) {
	var newTask models.Task
	if err := c.ShouldBindJSON(&newTask); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	newTask.ID = nextID
	nextID++
	tasks = append(tasks, newTask)
	c.JSON(http.StatusCreated, newTask)
}

// PATCH /tasks/:id
func updateTask(c *gin.Context) {
	idParam := c.Param("id")
	id, err := strconv.Atoi(idParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	var updatedTask models.Task
	if err := c.ShouldBindJSON(&updatedTask); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	for i, t := range tasks {
		if t.ID == id {
			// Update fields yang dikirim
			if updatedTask.Title != "" {
				tasks[i].Title = updatedTask.Title
			}
			if updatedTask.Description != "" {
				tasks[i].Description = updatedTask.Description
			}
			if updatedTask.Status != "" {
				tasks[i].Status = updatedTask.Status
			}
			c.JSON(http.StatusOK, tasks[i])
			return
		}
	}

	c.JSON(http.StatusNotFound, gin.H{"error": "Task not found"})
}

// DELETE /tasks/:id
func deleteTask(c *gin.Context) {
	idParam := c.Param("id")
	id, err := strconv.Atoi(idParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	for i, t := range tasks {
		if t.ID == id {
			tasks = append(tasks[:i], tasks[i+1:]...)
			c.JSON(http.StatusOK, gin.H{"message": "Task deleted"})
			return
		}
	}

	c.JSON(http.StatusNotFound, gin.H{"error": "Task not found"})
}
