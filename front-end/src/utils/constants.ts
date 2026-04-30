const IP = import.meta.env.VITE_API_IP || "localhost";

export const USER_API = `http://${IP}:3001`;
export const PRODUCT_API = `http://${IP}:3002`;
export const CART_API = `http://${IP}:3003`;