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
    data() {
        return {
            loading: false,
        }
    },
    mounted() {
    },
    methods: {

        loadingIndicator(el, state=true) {

            if (state === true) {
                el.classList.add("fa-spin")
                return
            }

            el.classList.remove("fa-spin")
            this.$router.go()

        },

        postDeploy(e) {
            this.loading = true
            this.loadingIndicator(e.target)
            this.http.post("/babel/translations/resources/deploy.json").then(result => {
                if (!result.successful) { this.alert("Error", "danger")}
                this.alert("Translations deploy process done successfully")
            }).catch(error => {
                console.log(error)
            }).finally(() => {
                this.loadingIndicator(e.target, false)
                this.loading = false
            })
        },

        postSync(e) {
            this.loading = true
            this.loadingIndicator(e.target)
            this.http.post("/babel/translations/resources/synchronization.json").then(result => {
                if (!result.successful) {
                    this.alert("Error", "danger")
                    return 
                }
                this.alert("Synchronization successfully")
            }).catch(error => {
                console.log(error)
            }).finally(() => {
                this.loadingIndicator(e.target, false)
                this.loading = false
            })
        },

        postUpdate(e) {
            this.loading = true
            this.loadingIndicator(e.target)
            this.http.post("/babel/translations/resources/renovate.json").then(result => {
                if (!result.successful) {
                    this.alert("Error", "danger")
                    return 
                }
                this.alert("Update successfully")
            }).catch(error => {
                console.log(error)
            }).finally(() => {
                this.loadingIndicator(e.target, false)
                this.loading = false
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

        <button v-if="!all_actions" @click="postDeploy" class="button is-primary" :disabled="loading">
            <b-icon icon="rocket" size="is-small" />
            <span>deploy</span>
        </button>

        <button v-if="!all_actions" @click="postSync" class="button is-primary" :disabled="loading">
            <b-icon icon="sync" size="is-small" />
            <span>sync</span>
        </button>

        <button v-if="!all_actions" @click="postUpdate" class="button is-primary" :disabled="loading">
            <span class="icon">
                <i class="fas fa-download"></i>
            </span>
            <span>update</span>
        </button>



        <button v-if="all_actions" @click="postDeploy" class="button is-primary"  :disabled="loading">
            <b-icon icon="rocket" size="is-small" />
        </button>

        <button v-if="all_actions" @click="postSync" class="button is-primary"  :disabled="loading">
            <b-icon icon="sync" size="is-small" />
        </button>

        <button v-if="all_actions" @click="postUpdate" class="button is-primary"  :disabled="loading">
            <span class="icon">
                <i class="fas fa-download"></i>
            </span>
        </button>

        <a v-if="all_actions && module_id" :href="getDownloadTranslation('android')" class="button is-primary"  :disabled="loading">
            <span class="icon">
                <i class="fab fa-android"></i>
            </span>
        </a>

        <a v-if="all_actions && module_id" :href="getDownloadTranslation('ios')" class="button is-primary"  :disabled="loading">
            <span class="icon">
                <i class="fab fa-swift"></i>
            </span>
        </a>

        <a v-if="all_actions && module_id" :href="getDownloadTranslation('flutter')" class="button is-primary"  :disabled="loading">
            <span class="icon">
                <i class="fas fa-ghost"></i>
            </span>
        </a>
    </div>
</template>
