import axios from "axios"

// In development, use localhost
// In production, use relative path
const baseURL = process.env.NODE_ENV === 'production' 
  ? '/api' 
  : "http://localhost:8000/api";

const instance = axios.create({
    baseURL: baseURL
})

export default instance