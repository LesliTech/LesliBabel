<script setup>

// · import lesli stores
import { useTranslations } from "CloudBabel/stores/translations"


// · implement stores
const storeTranslations = useTranslations()

</script>
<template>
    <nav class="level mb-4 pb-4">
        <div class="level-left">
            <div class="level-item">
                <lesli-button icon="download" @click="storeTranslations.postRenovate()">
                    update
                </lesli-button>
            </div>
            <div class="level-item">
                <lesli-button icon="rocket_launch" @click="storeTranslations.postDeploy()">
                    deploy
                </lesli-button>
            </div>
            <div class="level-item">
                <lesli-button icon="sync" @click="storeTranslations.postSync()">
                    sync
                </lesli-button>
            </div>
        </div>

        <div class="level-right">
            <div class="level-item">
                <lesli-button icon="code">
                    javascript
                </lesli-button>
            </div>
            <div class="level-item">
                <lesli-button icon="code">
                    flutter
                </lesli-button>
            </div>
        </div>
    </nav>
</template>
