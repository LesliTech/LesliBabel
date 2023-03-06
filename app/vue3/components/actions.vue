<script setup>

// · import lesli stores
import { useTranslations } from "CloudBabel/stores/translations"


// · implement stores
const storeTranslations = useTranslations()

</script>
<template>
    <lesli-button icon="download" @click="storeTranslations.postRenovate()">
        update
    </lesli-button>
    <lesli-button icon="rocket_launch" @click="storeTranslations.postDeploy()">
        deploy
    </lesli-button>
    <lesli-button icon="sync" @click="storeTranslations.postSync()">
        sync
    </lesli-button>
    <!--
    <lesli-button icon="code">
        javascript
    </lesli-button>
    <lesli-button icon="code">
        flutter
    </lesli-button>
    -->
</template>
