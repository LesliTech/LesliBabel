<script>
/*
Lesli

Copyright (c) 2019, Lesli Technologies, S. A.

All the information provided by this website is protected by laws of Guatemala related 
to industrial property, intellectual property, copyright and relative international laws. 
Lesli Technologies, S. A. is the exclusive owner of all intellectual or industrial property
rights of the code, texts, trade mark, design, pictures and any other information.
Without the written permission of Lesli Technologies, S. A., any replication, modification,
transmission, publication is strictly forbidden.
For more information read the license file including with this software.

LesliCloud - Your Smart Business Assistant

Powered by https://www.lesli.tech
Building a better future, one line of code at a time.

@author   LesliTech <hello@lesli.tech>
@license  Propietary - all rights reserved.
@version  0.1.0-alpha

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
*/
// · Component
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
export default {
    data(){
        return{
            translation_object_string_id: null,
            translation_object_id: null,
            translation_id: null,
            translation_object_string: {}
        }
    },
    mounted(){
        this.translation_id = this.$route.params.translation_id
        this.translation_object_id = this.$route.params.translation_object_id
        this.translation_object_string_id = this.$route.params.id
        this.getTranslationObjectStrings()
   },
   methods: {
        getTranslationObjectStrings() {
        this.http.get(`/babel/translations/${this.translation_id}/translation_objects/${this.translation_object_id}/translation_object_strings/${this.translation_object_string_id}.json`).then(result => {
            if (result.successful) {
                this.translation_object_string = result.data
            }
        }).catch(error => {
            console.log(error)
        })
        },
        PutTranslationObjectStrings(e) {
            if (e) { e.preventDefault() }
            this.http.put(`/babel/translations/${this.translation_id}/translation_objects/${this.translation_object_id}/translation_object_strings/${this.translation_object_string_id}`, {
                 translation_object_string: this.translation_object_string
            }).then(result => {
                if (result.successful) {
                    this.alert("Translation object string updated successfuly")
                    this.$router.push(`/translations/${this.translation_id}/translation_objects/${this.translation_object_id}/translation_object_strings`)
                }
            }).catch(error => {
                console.log(error)
            })
        },
   }
}
</script>
<template>
    <section class="section">
        <div class="card">
            <div class="card-header">
                <h4 class="card-header-title">
                    Edit translation object string
                </h4>
            </div>
            <div class="card-content">
                <form @submit="PutTranslationObjectStrings">
                    <div class="field is-horizontal">
                        <div class="field-body">
                            <div class="field">
                                <p class="control is-expanded">
                                    <input class="input" type="text" required placeholder="Entry" v-model="translation_object_string.label">
                                </p>
                            </div>
                            <div class="field">
                                <p class="control is-expanded">
                                    <input class="input" type="text" required placeholder="Spanish" v-model="translation_object_string.es">
                                </p>
                            </div>
                            <div class="field">
                                <p class="control is-expanded">
                                    <input class="input" type="text" required placeholder="English" v-model="translation_object_string.en">
                                </p>
                            </div>
                            <div class="field">
                                <p class="control is-expanded">
                                    <input class="input" type="text" required placeholder="German" v-model="translation_object_string.de">
                                </p>
                            </div>
                            <div class="field">
                                <p class="control is-expanded">
                                    <input class="input" type="text" required placeholder="French" v-model="translation_object_string.fr">
                                </p>
                            </div>
                            <div class="field">
                                <div class="control">
                                    <button class="button is-primary">
                                        Save
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </section>
</template>
