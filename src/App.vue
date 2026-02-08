<script setup>
import { ref, reactive, onMounted } from 'vue'

const API_BASE = window.__ENV__.API_BASE

const items = ref([])
const showList = ref(true)
const loading = ref(false)
const message = ref('')

// Search
const searchId = ref('')
const searchResult = ref(null)

// Create
const newItem = reactive({ title: '', description: '' })

// Update
const updateId = ref('')
const updateField = ref('title')
const updateValue = ref('')

// Delete
const deleteId = ref('')

const fetchAll = async () => {
	loading.value = true
	message.value = ''
	try {
		const res = await fetch(`${API_BASE}/items`)
		items.value = await res.json()
	} catch (e) {
		message.value = 'Fetch error: ' + e.message
	} finally {
		loading.value = false
	}
}

const fetchById = async () => {
	if (!searchId.value) return (message.value = 'Enter id')
	message.value = ''
	try {
		const res = await fetch(`${API_BASE}/items/${encodeURIComponent(searchId.value)}`)
		if (res.status === 404) return (searchResult.value = null, message.value = 'Not found')
		searchResult.value = await res.json()
	} catch (e) {
		message.value = 'Fetch error: ' + e.message
	}
}

const createItem = async () => {
	if (!newItem.title) return (message.value = 'Title required')
	message.value = ''
	try {
		const res = await fetch(`${API_BASE}/items`, {
			method: 'POST',
			headers: { 'Content-Type': 'application/json' },
			body: JSON.stringify(newItem),
		})
		if (res.status >= 400) {
			const j = await res.json().catch(() => ({}))
			return (message.value = j.error || 'Create failed')
		}
		const created = await res.json()
		message.value = 'Created id ' + (created?.id || '(unknown)')
		newItem.title = ''
		newItem.description = ''
		await fetchAll()
	} catch (e) {
		message.value = 'Create error: ' + e.message
	}
}

const updateItem = async () => {
	if (!updateId.value) return (message.value = 'Enter id')
	if (!updateValue.value) return (message.value = 'Enter value')
	message.value = ''
	try {
		// build body depending on selected field (send only the selected field)
		let body = {}
		if (updateField.value === 'title') body = { title: updateValue.value }
		else body = { description: updateValue.value }

		const res = await fetch(`${API_BASE}/items/${encodeURIComponent(updateId.value)}`, {
			method: 'PUT',
			headers: { 'Content-Type': 'application/json' },
			body: JSON.stringify(body),
		})
		if (res.status === 404) return (message.value = 'Not found')
		if (res.status >= 400) {
			const j = await res.json().catch(() => ({}))
			return (message.value = j.error || 'Update failed')
		}
		const updated = await res.json()
		message.value = 'Updated id ' + (updated?.id || updateId.value)
		updateId.value = ''
		updateValue.value = ''
		await fetchAll()
	} catch (e) {
		message.value = 'Update error: ' + e.message
	}
}

const deleteItem = async () => {
	if (!deleteId.value) return (message.value = 'Enter id')
	message.value = ''
	try {
		const res = await fetch(`${API_BASE}/items/${encodeURIComponent(deleteId.value)}`, { method: 'DELETE' })
		if (res.status === 404) return (message.value = 'Not found')
		if (res.status >= 400) return (message.value = 'Delete failed')
		message.value = 'Deleted id ' + deleteId.value
		deleteId.value = ''
		await fetchAll()
	} catch (e) {
		message.value = 'Delete error: ' + e.message
	}
}

onMounted(() => {
	fetchAll()
})
</script>

<template>
	<div class="container">
		<h1>CRUD Playground 67026371 & 67022568.</h1>

		<section class="card">
			<h2 @click="showList = !showList" style="cursor:pointer">List items <small>click to toggle</small></h2>
			<div v-if="showList">
				<div class="controls">
					<button @click="fetchAll" :disabled="loading">Fetch</button>
					<span v-if="loading">Loading...</span>
				</div>
				<table class="items">
					<thead>
						<tr><th>id</th><th>title</th><th>description</th><th>created_at</th><th>updated_at</th></tr>
					</thead>
					<tbody>
						<tr v-for="it in items" :key="it.id">
							<td>{{ it.id }}</td>
							<td>{{ it.title }}</td>
							<td>{{ it.description }}</td>
							<td>{{ it.created_at }}</td>
							<td>{{ it.updated_at }}</td>
						</tr>
					</tbody>
				</table>
			</div>
		</section>

		<section class="card">
			<h2>Search by ID</h2>
			<div class="row">
				<input v-model="searchId" placeholder="id" />
				<button @click="fetchById">Search</button>
			</div>
			<pre v-if="searchResult">{{ JSON.stringify(searchResult, null, 2) }}</pre>
		</section>

		<section class="card">
			<h2>Create item</h2>
			<div class="row">
				<input v-model="newItem.title" placeholder="title" />
				<input v-model="newItem.description" placeholder="description" />
				<button @click="createItem">Create</button>
			</div>
		</section>

		<section class="card">
			<h2>Update item</h2>
			<div class="row">
				<input v-model="updateId" placeholder="id" />
				<select v-model="updateField">
					<option value="title">title</option>
					<option value="description">description</option>
				</select>
				<input v-model="updateValue" placeholder="new value" />
				<button @click="updateItem">Update</button>
			</div>
		</section>

		<section class="card">
			<h2>Delete item</h2>
			<div class="row">
				<input v-model="deleteId" placeholder="id" />
				<button @click="deleteItem">Delete</button>
			</div>
		</section>

		<div class="status" v-if="message">{{ message }}</div>
	</div>
</template>

<style scoped>
/* พื้นหลังแบบไล่สีพาสเทลหลายมิติ */
body {
    margin: 0;
    min-height: 100vh;
    background: radial-gradient(at 0% 0%, #fff1f2 0%, transparent 50%), 
                radial-gradient(at 100% 0%, #f5f3ff 0%, transparent 50%), 
                radial-gradient(at 100% 100%, #fdf2f8 0%, transparent 50%), 
                radial-gradient(at 0% 100%, #faf5ff 0%, transparent 50%);
    background-color: #ffffff;
    background-attachment: fixed;
}

.container {
    max-width: 900px;
    margin: 40px auto;
    /* เปลี่ยนมาใช้ฟอนต์ Itim */
    font-family: 'Itim', cursive;
    /* เอฟเฟกต์กระจกฝ้า */
    background: rgba(255, 255, 255, 0.6);
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    padding: 30px;
    border-radius: 24px;
    border: 1px solid rgba(255, 255, 255, 0.7);
    box-shadow: 0 8px 32px 0 rgba(236, 72, 153, 0.1);
}

.muted {
    color: #a78bfa;
    font-size: 0.95rem;
}

.card {
    border: 2px solid rgba(243, 232, 255, 0.7);
    background-color: rgba(255, 255, 255, 0.8);
    padding: 20px;
    border-radius: 18px;
    margin-bottom: 20px;
    box-shadow: 0 10px 15px -3px rgba(255, 192, 203, 0.2);
    transition: transform 0.2s ease;
}

.card:hover {
    transform: translateY(-3px);
}

.row {
    display: flex;
    gap: 12px;
    align-items: center;
    margin-top: 10px;
}

input, select {
    font-family: 'Itim', cursive;
    padding: 10px 15px;
    border: 2px solid #fbcfe8;
    border-radius: 12px;
    outline: none;
    background: white;
    transition: all 0.3s;
}

input:focus, select:focus {
    border-color: #d8b4fe;
    box-shadow: 0 0 0 4px rgba(216, 180, 254, 0.2);
}

button {
    font-family: 'Itim', cursive; 
    padding: 10px 20px;
    border-radius: 12px;
    border: none;
    background: linear-gradient(135deg, #fda4af 0%, #d8b4fe 100%);
    color: white;
    font-weight: 600;
    font-size: 1rem;
    cursor: pointer;
    box-shadow: 0 4px 12px rgba(244, 114, 182, 0.3);
    transition: all 0.2s ease;
}

button:hover {
    transform: scale(1.05);
    filter: brightness(1.05);
}

.items {
    width: 100%;
    border-collapse: separate;
    border-spacing: 0;
    margin-top: 15px;
    border-radius: 15px;
    overflow: hidden;
    border: 1px solid #f3e8ff;
    background: white;
}

.items th {
    background-color: #fdf2f8;
    color: #be185d;
    padding: 12px;
    font-size: 1.1rem;
}

.items td {
    border-bottom: 1px solid #f3e8ff;
    padding: 12px;
    color: #6b21a8;
}

.status {
    margin-top: 20px;
    color: #db2777;
    font-weight: 600;
    font-size: 1.1rem;
    text-align: center;
}

h1 {
    color: #9333ea;
    text-shadow: 2px 2px 0px #fdf2f8;
    margin-bottom: 8px;
    text-align: center;
}

h2 {
    margin: 0;
    font-size: 1.2rem;
    color: #db2777;
}
</style>