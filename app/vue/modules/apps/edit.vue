<script>


export default {
    data() {
        return {
            module_id: null,
            module: {},
            bucket: {},
            buckets: [],
            columns: [{
                field: "id",
                label: "ID",
                width: "40"
            }, {
                field: "name",
                label: "Name",
            }]
        }
    },
    mounted() {
        this.module_id = this.$route.params.id
        this.getModule()
        this.getBuckets()
    },
    methods: {

        getModule() {
            this.http.get(`/babel/modules/${this.module_id}.json`).then(result => {
                this.module = result.data
            }).catch(error => {
                console.log(error)
            })
        },

        getBuckets() {
            this.http.get(`/babel/modules/${this.module_id}/buckets.json`).then(result => {
                this.buckets = result.data
            }).catch(error => {
                console.log(error)
            })
        },

        postBucket() {
            this.http.post(`/babel/modules/${this.module_id}/buckets.json`, {
                bucket: this.bucket
            }).then(result => {
                this.bucket = {}
                this.getBuckets()
                this.alert("Bucket created")
            }).catch(error => {
                console.log(error)
            })
        }
    }
}
</script>
<template>
    <section class="application-component">
        <component-header :title="module.name "></component-header>

        <div class="card">
            <div class="card-content">
                <form @submit.prevent="postBucket()">
                    <div class="field">
                        <label class="label">Name</label>
                        <div class="control">
                            <input class="input" type="text" placeholder="Bucket name" v-model="bucket.name">
                        </div>
                    </div>
                    <div class="field is-grouped">
                        <div class="control">
                            <button class="button is-primary">Save</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
        <div class="card">
            <div class="card-content">
                <b-table 
                    :data="buckets" 
                    :columns="columns">
                </b-table>
            </div>
        </div>

    </section>
</template>
