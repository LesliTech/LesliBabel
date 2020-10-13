<script>
export default {
    props: {
        all_actions: {
            default: false
        },
        module_id: {
            default: null
        }
    },
    mounted() {
        console.log(this.all_actions)
    },
    methods: {

        postDeploy() {
            this.loading = true
            this.http.post("/babel/translations/resources/deploy.json").then(result => {
                if (!result.successful) { this.alert("Error", "danger")}
                this.alert("Translations deploy process done successfully")
                this.loading = false
            }).catch(error => {
                console.log(error)
            })
        },

        postSync() {
            this.loading = true
            this.http.post("/babel/translations/resources/synchronization.json").then(result => {
                if (!result.successful) {
                    this.alert("Error", "danger")
                    return 
                }
                this.getModules()
                this.alert("Synchronization successfully")
                this.loading = false
            }).catch(error => {
                console.log(error)
            })
        },

        getDownloadTranslation(platform) {
            return "/babel/translations/resources/download.json?engine_id="+this.module_id+"&platform="+platform
        }

    }
}
</script>
<template>
    <div class="is-grouped">

        <button v-if="!all_actions" @click="postDeploy" class="button is-primary">
            <b-icon icon="rocket" size="is-small" />
            <span>deploy</span>
        </button>

        <button v-if="!all_actions" @click="postSync" class="button is-primary">
            <b-icon icon="sync" size="is-small" />
            <span>sync</span>
        </button>

        <button v-if="all_actions" @click="postDeploy" class="button is-primary">
            <b-icon icon="rocket" size="is-small" />
        </button>

        <button v-if="all_actions" @click="postSync" class="button is-primary">
            <b-icon icon="sync" size="is-small" />
        </button>

        <a v-if="all_actions && module_id" :href="getDownloadTranslation('android')" class="button is-primary">
            <span class="icon">
                <i class="fab fa-android"></i>
            </span>
        </a>

        <a v-if="all_actions && module_id" :href="getDownloadTranslation('ios')" class="button is-primary">
            <span class="icon">
                <i class="fab fa-swift"></i>
            </span>
        </a>
    </div>
</template>
