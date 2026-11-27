const style = document.createElement("style")
document.head.append(style)
const sheet = style.sheet

const stat_list = JSON.parse(document.getElementById("all_stats").text)
stat_list.forEach(stat => {
	const checkbox = document.getElementById(`checkbox_stat_${stat}`)

	function update_column(visible) {
		for (const data of document.querySelectorAll(`.stat_${stat}`)) {
			data.style.display = visible ? null : "none"
		}
	}
	checkbox.addEventListener("change", (event) => {
		update_column(event.target.checked)
	})
	update_column(checkbox.checked)
})

const pack_list = JSON.parse(document.getElementById("all_packs").text)
pack_list.forEach(pack => {
	const checkbox = document.getElementById(`checkbox_pack_${pack}`)
	function update_row(visible) {
		for (const row of document.querySelectorAll(`.pack_${pack}`)) {
			row.style.display = visible ? null : "none"
		}
	}
	checkbox.addEventListener("change", (event) => {
		update_row(event.target.checked)
	})
	update_row(checkbox.checked)
})