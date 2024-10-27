namespace Tarea3BD1.Models
{ 
    public class EmpleadoMovimientosViewModel
    {
        public int ValorDocumentoIdentidad { get; set; }
        public string Nombre { get; set; }
        public int SaldoVacaciones { get; set; }
        public List<Movimiento> Movimientos { get; set; }
    }

    public class Movimiento
    {
        public DateTime Fecha { get; set; }
        public string TipoMovimiento { get; set; }
        public decimal Monto { get; set; }
        public int NuevoSaldo { get; set; }
        public string UsuarioRegistro { get; set; }
        public string IP { get; set; }
        public DateTime TimeStamp { get; set; }
        public object? IdEmpleado { get; internal set; }
    }
}