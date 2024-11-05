import UIKit

class ViewControllerEditarPerfil: UIViewController {
    
    @IBOutlet weak var txtNombre: UITextField!
    @IBOutlet weak var txtClave: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    
    var usuario: Users?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Verificar que tenemos los datos del usuario
        print("Usuario recibido:", usuario ?? "No hay usuario")
        
        // Cargar los datos del usuario
        if let user = usuario {
            txtNombre.text = user.nombre
            txtClave.text = user.clave
            txtEmail.text = user.email
        }
    }
    
    @IBAction func btnGuardar(_ sender: Any) {
        guard let user = usuario else {
            mostrarAlerta(titulo: "Error", mensaje: "No se encontraron datos del usuario")
            return
        }
        
        guard let nombre = txtNombre.text, !nombre.isEmpty,
              let clave = txtClave.text, !clave.isEmpty,
              let email = txtEmail.text, !email.isEmpty else {
            mostrarAlerta(titulo: "Error", mensaje: "Todos los campos son obligatorios")
            return
        }
        
        let datos: [String: Any] = [
            "nombre": nombre,
            "clave": clave,
            "email": email
        ]
        
        let ruta = "http://localhost:3000/usuarios/\(user.id)"
        metodoPUT(ruta: ruta, datos: datos)
    }
    
    func metodoPUT(ruta: String, datos: [String: Any]) {
        let url = URL(string: ruta)!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: datos)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.mostrarAlerta(titulo: "Error", mensaje: "Error al actualizar: \(error.localizedDescription)")
                        return
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse,
                       (200...299).contains(httpResponse.statusCode) {
                        self?.mostrarAlerta(titulo: "Éxito", mensaje: "Perfil actualizado correctamente")
                        self?.navigationController?.popViewController(animated: true)
                    } else {
                        self?.mostrarAlerta(titulo: "Error", mensaje: "Error al actualizar el perfil")
                    }
                }
            }.resume()
            
        } catch {
            mostrarAlerta(titulo: "Error", mensaje: "Error al procesar los datos")
        }
    }
    
    func mostrarAlerta(titulo: String, mensaje: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let btnOK = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            if titulo == "Éxito" {
                self?.navigationController?.popViewController(animated: true)
            }
        }
        alerta.addAction(btnOK)
        present(alerta, animated: true)
    }
}
