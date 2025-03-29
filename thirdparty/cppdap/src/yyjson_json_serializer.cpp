// Copyright 2019 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include "yyjson_json_serializer.h"

#include "null_json_serializer.h"

namespace dap {
    namespace json {

        yyjsonDeserializer::yyjsonDeserializer(const std::string &str) :
            doc(yyjson_read(str.data(), str.size(), 0)),
            val(yyjson_doc_get_root(doc)),
            ownsJson(true)
        {
        }

        yyjsonDeserializer::yyjsonDeserializer(yyjson_doc *doc, yyjson_val *val) :
            doc(doc),
            val(val ? val : yyjson_doc_get_root(doc)),
            ownsJson(false)
        {
        }

        yyjsonDeserializer::~yyjsonDeserializer() {
            if(ownsJson) {
                yyjson_doc_free(doc);
            }
        }

        bool yyjsonDeserializer::deserialize(dap::boolean *v) const {
            if(!yyjson_is_bool(val)) {
                return false;
            }
            *v = yyjson_get_bool(val);
            return true;
        }


        bool yyjsonDeserializer::deserialize(dap::integer *v) const {
            if(!yyjson_is_int(val)) {
                return false;
            }
            *v = yyjson_is_sint(val) ? yyjson_get_sint(val) : yyjson_get_uint(val);
            return true;
        }

        bool yyjsonDeserializer::deserialize(dap::number *v) const {
            if(!yyjson_is_num(val)) {
                return false;
            }
            *v = yyjson_get_num(val);
            return true;
        }

        bool yyjsonDeserializer::deserialize(dap::string *v) const {
            if(!yyjson_is_str(val)) {
                return false;
            }
            *v = dap::string(yyjson_get_str(val), yyjson_get_len(val));
            return true;
        }

        bool yyjsonDeserializer::deserialize(dap::object *v) const {
            v->reserve(yyjson_get_len(val));
            yyjson_obj_iter iter;
            yyjson_obj_iter_init(val, &iter);
            yyjson_val *key, *val;
            while((key = yyjson_obj_iter_next(&iter))) {
                val = yyjson_obj_iter_get_val(key);
                yyjsonDeserializer d(doc, val);
                dap::any val;
                if(!d.deserialize(&val)) {
                    return false;
                }
                (*v)[dap::string(yyjson_get_str(key), yyjson_get_len(key))] = val;
            }
            return true;
        }

        bool yyjsonDeserializer::deserialize(dap::any *v) const {
            if(yyjson_is_bool(val)) {
                *v = dap::boolean(yyjson_get_bool(val));
            }
            else if(yyjson_is_real(val)) {
                *v = dap::number(yyjson_get_real(val));
            }
            else if(yyjson_is_int(val)) {
                *v = dap::integer(yyjson_is_sint(val) ? yyjson_get_sint(val) : yyjson_get_uint(val));
            }
            else if(yyjson_is_str(val)) {
                *v = dap::string(yyjson_get_str(val), yyjson_get_len(val));
            }
            else if(yyjson_is_obj(val)) {
                dap::object obj;
                if(!deserialize(&obj)) {
                    return false;
                }
                *v = obj;
            }
            else if(yyjson_is_arr(val)) {
                dap::array<any> arr;
                if(!deserialize(&arr)) {
                    return false;
                }
                *v = arr;
            }
            else if(yyjson_is_null(val)) {
                *v = null();
            }
            else {
                return false;
            }
            return true;
        }

        size_t yyjsonDeserializer::count() const {
            return yyjson_get_len(val);
        }

        bool yyjsonDeserializer::array(
            const std::function<bool(dap::Deserializer *)> &cb) const {
            if(!yyjson_is_arr(val)) {
                return false;
            }
            size_t idx, max;
            yyjson_val *value;
            yyjson_arr_foreach(val, idx, max, value) {
                yyjsonDeserializer d(doc, value);
                if(!cb(&d)) {
                    return false;
                }
            }
            return true;
        }

        bool yyjsonDeserializer::field(
            const std::string &name,
            const std::function<bool(dap::Deserializer *)> &cb) const {
            if(!yyjson_is_obj(val)) {
                return false;
            }
            auto value = yyjson_obj_getn(val, name.data(), name.size());
            if(value == nullptr) {
                return cb(&NullDeserializer::instance);
            }
            yyjsonDeserializer d(doc, value);
            return cb(&d);
        }

        yyjsonSerializer::yyjsonSerializer()
            : doc(yyjson_mut_doc_new(NULL)), val(yyjson_mut_obj(doc)), ownsJson(true) {
            yyjson_mut_doc_set_root(doc, val);
        }

        yyjsonSerializer::yyjsonSerializer(yyjson_mut_doc *doc, yyjson_mut_val *val)
            : doc(doc), val(val), ownsJson(false) {
        }

        yyjsonSerializer::~yyjsonSerializer() {
            if(ownsJson) {
                yyjson_mut_doc_free(doc);
            }
        }

        std::string yyjsonSerializer::dump() const {
            size_t len;
            char *p = yyjson_mut_val_write(val, 0, &len);
            std::string s(p, len);
            free(p);
            return s;
        }

        bool yyjsonSerializer::serialize(dap::boolean v) {
            yyjson_mut_set_bool(val, (bool) v);
            return true;
        }

        bool yyjsonSerializer::serialize(dap::integer v) {
            yyjson_mut_set_sint(val, v);
            return true;
        }

        bool yyjsonSerializer::serialize(dap::number v) {
            yyjson_mut_set_real(val, v);
            return true;
        }

        bool yyjsonSerializer::serialize(const dap::string &v) {
            yyjson_mut_val *mem = yyjson_mut_strncpy(doc, v.data(), v.length());
            yyjson_mut_set_strn(val, yyjson_mut_get_str(mem), yyjson_mut_get_len(mem));
            return true;
        }

        bool yyjsonSerializer::serialize(const dap::object &v) {
            if(!yyjson_mut_is_obj(val)) {
                yyjson_mut_set_obj(val);
            }
            for(auto &it : v) {
                yyjson_mut_val *sv = yyjson_mut_null(doc);
                yyjsonSerializer s(doc, sv);
                if(!s.serialize(it.second)) {
                    return false;
                }
                yyjson_mut_obj_add(val, yyjson_mut_strncpy(doc, it.first.data(), it.first.size()), sv);
            }
            return true;
        }

        bool yyjsonSerializer::serialize(const dap::any &v) {
            if(v.is<dap::boolean>()) {
                yyjson_mut_set_bool(val, (bool) v.get<dap::boolean>());
            }
            else if(v.is<dap::integer>()) {
                yyjson_mut_set_sint(val, v.get<dap::integer>());
            }
            else if(v.is<dap::number>()) {
                yyjson_mut_set_real(val, (double) v.get<dap::number>());
            }
            else if(v.is<dap::string>()) {
                yyjson_mut_val *mem = yyjson_mut_strncpy(doc, v.get<dap::string>().data(), v.get<dap::string>().length());
                yyjson_mut_set_strn(val, yyjson_mut_get_str(mem), yyjson_mut_get_len(mem));
            }
            else if(v.is<dap::object>()) {
                // reachable if dap::object nested is inside other dap::object
                return serialize(v.get<dap::object>());
            }
            else if(v.is<dap::null>()) {
            }
            else {
                // reachable if array or custom serialized type is nested inside other
                auto type = get_any_type(v);
                auto value = get_any_val(v);
                if(type && value) {
                    return type->serialize(this, value);
                }
                return false;
            }
            return true;
        }

        bool yyjsonSerializer::array(size_t count,
            const std::function<bool(dap::Serializer *)> &cb) {
            if(!yyjson_mut_is_arr(val)) {
                yyjson_mut_set_arr(val);
            }
            for(size_t i = 0; i < count; i++) {
                yyjson_mut_val *sv = yyjson_mut_null(doc);
                yyjsonSerializer s(doc, sv);
                if(!cb(&s)) {
                    return false;
                }
                yyjson_mut_arr_append(val, sv);
            }
            return true;
        }

        bool yyjsonSerializer::object(
            const std::function<bool(dap::FieldSerializer *)> &cb) {
            struct FS : public FieldSerializer {
                yyjson_mut_doc *const doc;
                yyjson_mut_val *const val;

                FS(yyjson_mut_doc *doc, yyjson_mut_val *val) : doc(doc), val(val) {}
                bool field(const std::string &name, const SerializeFunc &cb) override {
                    yyjson_mut_val *sv = yyjson_mut_null(doc);
                    yyjsonSerializer s(doc, sv);
                    auto res = cb(&s);
                    if(!s.removed) {
                        yyjson_mut_obj_put(val, yyjson_mut_strncpy(doc, name.data(), name.length()), sv);
                    }
                    return res;
                }
            };

            yyjson_mut_set_obj(val);
            FS fs { doc, val };
            return cb(&fs);
        }

        void yyjsonSerializer::remove() {
            removed = true;
        }

    }  // namespace json
}  // namespace dap
