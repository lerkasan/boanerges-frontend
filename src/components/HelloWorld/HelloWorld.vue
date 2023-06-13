<template>
    <div>
        <ul v-if="books">
            <li v-for="book in books" :key="book.id">
                {{ book.title }}
            </li>
        </ul>
    </div>
</template>


<script setup>

import {ref} from "vue";

async function getBooks() {
    const response = await fetch('http://localhost:8080/api/v1/books');

    if (!response.ok) {
        const message = `An error has occurred: ${response.status}`;
        throw new Error(message);
    }

    return response.json();
}

const result = await getBooks().catch(error => {
    error.message;
});

const books = ref(result);

</script>


<style scoped lang="css">
    li {
        list-style-type: none;
    }
</style>