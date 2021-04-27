<script>
export default {
    data() {
        return {
            module: {
                name:"",
                platform: ""
            }
        }
    },
    methods: {

        postModule() {
            if (this.module.name == "" || this.module.module_type == "") {
                this.alert("Please complete the form", "warning")
                return
            }
            this.http.post("/babel/modules", {
                module: this.module
            }).then(result => {

                this.alert("New module created")
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
                                        <select v-model="module.platform">
                                            <option value="js">JS</option>
                                            <option value="standard">Standard</option>
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
