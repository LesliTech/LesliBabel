<script>
export default {
    data() {
        return {
            module: {
                name:"ldonis",
                module_type: ""
            }
        }
    },
    methods: {

        postModule() {
            console.log(this.module)
            this.http.post("/babel/modules", {
                module: this.module
            }).then(result => {
                console.log(result)
            }).catch(error => {
                console.log(error)
            })
        }

    }
}
</script>
<template>
    <section class="application-component">
        <component-header title="Add new module or device"></component-header>
        <div class="card">
            <div class="card-content">
                <form @submit.prevent="postModule()">
                    <div class="field is-horizontal">
                        <div class="field-body">
                            <div class="field">
                                <p class="control">
                                    <input class="input" type="text" placeholder="Device name" v-model="module.name">
                                </p>
                            </div>
                            <div class="field">
                                <div class="control">
                                    <div class="select">
                                        <select v-model="module.module_type">
                                            <option value="android">Android</option>
                                            <option value="ios">iOS</option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="field is-grouped">
                        <div class="control">
                            <input type="submit" value="Save" class="button is-link">
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </section>
</template>
