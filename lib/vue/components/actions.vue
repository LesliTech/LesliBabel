<script setup>

// · import lesli stores
import { useTranslations } from "LesliBabel/vue/stores/translations"


// · implement stores
const storeTranslations = useTranslations()

</script>
<template>
    <lesli-button icon="rocket_launch" @click="storeTranslations.postDeploy()">
        deploy
    </lesli-button>
    <!--
    <lesli-button icon="download">
        update
    </lesli-button>
    <lesli-button icon="sync" @click="storeTranslations.postSync()">
        sync
    </lesli-button>
    <lesli-button icon="code">
        javascript
    </lesli-button>
    <lesli-button icon="code">
        flutter
    </lesli-button>
    -->
</template>
