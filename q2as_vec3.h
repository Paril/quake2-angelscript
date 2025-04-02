struct vec3
{
	union
	{
		struct 
		{
			float x;
			float y;
			float z;
		};

		std::array<float, 3> Elements;
	};

	float &operator[] (unsigned int i) {
		i = i > 2 ? 0 : i;

		return Elements[i];
	}

	const float &operator[] (unsigned int i) const {
		i = i > 2 ? 0 : i;

		return Elements[i];
	}

	bool operator==(const vec3 &v) const {
		return *this == v;
	}

	bool equals(const vec3 &v, const float &epsilon) const {
		auto rx = abs(x - v.x) <= epsilon * max(1.0f, max(abs(x), abs(v.x)));
		auto ry = abs(y - v.y) <= epsilon * max(1.0f, max(abs(y), abs(v.y)));
		auto rz = abs(z - v.z) <= epsilon * max(1.0f, max(abs(z), abs(v.z)));

		return rx && ry && rz;
	}

	explicit operator bool() const {
		return x || y || z;
	}

	float dot(const vec3 &v) const {
		return x * v.x + y * v.y + z * v.z;
	}

	vec3 scaled(const vec3 &v) const {
		vec3 result = {};

		result.x = x * v.x;
		result.y = y * v.y;
		result.z = z * v.z;

		return result;
	}

	vec3 &scale(const vec3 &v) {
		x = x * v.x;
		y = y * v.y;
		z = z * v.z;

		return *this;
	}

	vec3 operator-(const vec3 &v) const {
		vec3 result = {};

		result.x = x - v.x;
		result.y = y - v.y;
		result.z = z - v.z;

		return result;
	}

	vec3 operator+(const vec3 &v) const {
		vec3 result = {};

		result.x = x + v.x;
		result.y = y + v.y;
		result.z = z + v.z;

		return result;
	}

	vec3 operator/(const vec3 &v) const {
		vec3 result = {};

		result.x = x / v.x;
		result.y = y / v.y;
		result.z = z / v.z;

		return result;
	}

	vec3 operator/(const float &v) const {
		vec3 result = {};

		result.x = x / v;
		result.y = y / v;
		result.z = z / v;

		return result;
	}

	vec3 operator/(const int &v) const {
		vec3 result = {};

		result.x = x / v;
		result.y = y / v;
		result.z = z / v;

		return result;
	}

	vec3 operator*(const float &v) const {
		vec3 result = {};

		result.x = x * v;
		result.y = y * v;
		result.z = z * v;

		return result;
	}

	vec3 operator*(const int &v) const {
		vec3 result = {};

		result.x = x * v;
		result.y = y * v;
		result.z = z * v;

		return result;
	}

	vec3 operator-() const {
		vec3 result = {};

		result.x = -x;
		result.y = -y;
		result.z = -z;

		return result;
	}

	vec3 &operator-=(const vec3 &v) {
		x -= v.x;
		y -= v.y;
		z -= v.z;

		return *this;
	}

	vec3 &operator+=(const vec3 &v) {
		x += v.x;
		y += v.y;
		z += v.z;

		return *this;
	}

	vec3 &operator/=(const vec3 &v) {
		x /= v.x;
		y /= v.y;
		z /= v.z;

		return *this;
	}

	vec3 &operator/=(const float &v) {
		x /= x;
		y /= y;
		z /= z;

		return *this;
	}

	vec3 &operator/=(const int &v) {
		x /= x;
		y /= y;
		z /= z;

		return *this;
	}

	vec3 &operator*=(const float &v) {
		x *= v;
		y *= v;
		z *= v;

		return *this;
	}

	vec3 &operator*=(const int &v) {
		x *= v;
		y *= v;
		z *= v;

		return *this;
	}

	float length() const {
		return sqrtf(lengthSquared());
	}

	float lengthSquared() const {
		return (x * x + y * y + z * z);
	}

	vec3 normalized() const {
		vec3 result = {x, y, z};
		result.normalize();

		return result;
	}

	vec3 normalized(float &v) const {
		vec3 result = { x, y, z };
		v = result.normalize();

		return result;
	}

	float normalize() {
		auto len = lengthSquared();
		if (len > 0) {
			len = 1 / sqrtf(len);
		}

		x *= len;
		y *= len;
		z *= len;

		return len;
	}

	vec3 cross(const vec3 &v) const {
		vec3 result = {};
		result.x = y * v.z - z * v.y;
		result.y = z * v.x - x * v.z;
		result.z = x * v.y - y * v.x;
		
		return result;
	}
};