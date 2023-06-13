<template>
    <Suspense>
        <HelloWorld/>
    </Suspense>
</template>

<script>
import HelloWorld from "@/components/HelloWorld/HelloWorld";

export default {
  name: 'App',
  components: {
    HelloWorld,
  }
}
</script>

<style src="./app.css" lang="css"></style>
