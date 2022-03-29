<script>
export default {
    props: {
        engineId: {
            default: null
        }
    },
    data() {
        return {
            loading: false,
        }
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
                if (!result.successful) {
                    this.msg.error("Error")
                    return
                }
                this.msg.success("Translations deploy process done successfully")
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
                    this.msg.error("Error")
                    return 
                }
                this.msg.success("Synchronization successfully")
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
                    this.msg.error("Error")
                    return 
                }
                this.msg.success("Update successfully")
            }).catch(error => {
                console.log(error)
            }).finally(() => {
                this.loadingIndicator(e.target, false)
                this.loading = false
            })
        },

        getDownloadTranslation(platform) {
            return "/babel/translations/resources/download.json?platform="+platform+"&engine="+this.engineId
        }

    }
}
</script>
<template>
    <b-dropdown
        position="is-bottom-left"
        append-to-body
        aria-role="menu">
        <template #trigger>
            <a class="navbar-item" role="button">
                <span>Options</span>
                <span class="icon is-small">
                    <i class="fas fa-angle-down" aria-hidden="true"></i>
                </span>
            </a>
        </template>
        <b-dropdown-item>
            <button @click="postDeploy" class="button is-white" :disabled="loading">
                <b-icon icon="rocket" size="is-small" />
                <span>deploy</span>
            </button>
        </b-dropdown-item>
        <b-dropdown-item>
            <button @click="postSync" class="button is-white" :disabled="loading">
                <b-icon icon="sync" size="is-small" />
                <span>sync</span>
            </button>
        </b-dropdown-item>
        <b-dropdown-item>
            <button @click="postUpdate" class="button is-white" :disabled="loading">
                <span class="icon">
                    <i class="fas fa-download"></i>
                </span>
                <span>update</span>
            </button>
        </b-dropdown-item>
        <b-dropdown-item v-if="engineId" :to="`/babel/modules/${engineId}/edit`">
            <router-link :to="`/babel/modules/${engineId}/edit`" class="button is-white">
                <span class="icon">
                    <i class="far fa-edit"></i>
                </span>
                <span>Add buckets</span>
            </router-link>
        </b-dropdown-item>
        <b-dropdown-item>
            <a :href="getDownloadTranslation('js')" class="button is-white"  :disabled="loading">
                <span class="icon">
                    <i class="fab fa-js"></i>
                </span>
                <span>JavaScript</span>
            </a>
        </b-dropdown-item>
        <b-dropdown-item v-if="engineId">
            <a :href="getDownloadTranslation('android')" class="button is-white"  :disabled="loading">
                <span class="icon">
                    <i class="fab fa-android"></i>
                </span>
                <span>Android</span>
            </a>
        </b-dropdown-item>
        <b-dropdown-item v-if="engineId">
            <a :href="getDownloadTranslation('swift')" class="button is-white"  :disabled="loading">
                <span class="icon">
                    <i class="fab fa-swift"></i>
                </span>
                <span>Swift</span>
            </a>
        </b-dropdown-item>
        <b-dropdown-item v-if="engineId">
            <a :href="getDownloadTranslation('flutter')" class="button is-white"  :disabled="loading">
                <span class="icon">
                    <i class="fas fa-ghost"></i>
                </span>
                <span>Flutter</span>
            </a>
        </b-dropdown-item>
        <b-dropdown-item v-if="engineId">
            <a :href="getDownloadTranslation('middleman')" class="button is-white"  :disabled="loading">
                <span class="icon">
                    <i class="far fa-gem"></i>
                </span>
                <span>Middleman</span>
            </a>
        </b-dropdown-item>
    </b-dropdown>
</template>
