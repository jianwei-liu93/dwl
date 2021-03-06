%module(directors="1") dwl
%{
#define SWIG_PYTHON_EXTRA_NATIVE_CONTAINERS 
#define SWIG_FILE_WITH_INIT
#include <Python.h>

// Robot-related core functions
#include <dwl/ReducedBodyState.h>
#include <dwl/WholeBodyState.h>
#include <dwl/model/FloatingBaseSystem.h>
#include <dwl/model/WholeBodyKinematics.h>
#include <dwl/model/WholeBodyDynamics.h>
#include <dwl/RobotStates.h>

// Optimization-related core functions
#include <dwl/model/OptimizationModel.h>
#include <dwl/solver/OptimizationSolver.h>
#include <dwl/solver/IpoptNLP.h>
#include <dwl/solver/cmaesSOFamily.h>

// Yaml parser
#include <dwl/utils/YamlWrapper.h>
%}


// typemaps.i is a built-in swig interface that lets us map c++ types to other
// types in our language of choice. We'll use it to map Eigen matrices to
// Numpy arrays.
%include <typemaps.i>
%include <std_string.i>
%include <std_vector.i>
%include <std_map.i>



////////////////////////////////////////////////////////////////////////////////////
/////////////////////////// Robot-related core functions ///////////////////////////
////////////////////////////////////////////////////////////////////////////////////
// eigen.i is found in ../swig/ and contains specific definitions to convert
// Eigen matrices into Numpy arrays.
%include <eigen.i>


%template(Matrix3d_List) std::vector<Eigen::Matrix3d>;
%template(Matrix4d_List) std::vector<Eigen::Matrix4d>;
%template(MatrixXd_List) std::vector<Eigen::MatrixXd>;
%template(Vector2d_List) std::vector<Eigen::Vector2d>;
%template(Vector3d_List) std::vector<Eigen::Vector3d>;
%template(VectorXd_List) std::vector<Eigen::VectorXd>;

// Since Eigen uses templates, we have to declare exactly which types we'd
// like to generate mappings for.
%eigen_typemaps(Eigen::Vector2d)
%eigen_typemaps(Eigen::Vector3d)
%eigen_typemaps(dwl::rbd::Vector6d)
%eigen_typemaps(Eigen::VectorXd)
%eigen_typemaps(Eigen::Matrix3d)
%eigen_typemaps(Eigen::Matrix4d)
%eigen_typemaps(Eigen::MatrixXd)
%eigen_typemaps(dwl::rbd::Matrix6d)
//%eigen_typemaps(Eigen::Quaterniond) TODO it doesn't work yet
// Even though Eigen::MatrixXd is just a typedef for Eigen::Matrix<double,
// Eigen::Dynamic, Eigen::Dynamic>, our templatedInverse function doesn't
// compile correctly unless we also declare typemaps for Eigen::Matrix<double,
// Eigen::Dynamic, Eigen::Dynamic>. Not totally sure why that is.
//%eigen_typemaps(Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic>)

%template(double_List) std::vector<double>;
%template(string_List) std::vector<std::string>;
%template(string_uint) std::map<std::string,unsigned int>;
%template(string_jointLimits) std::map<std::string,urdf::JointLimits>;


// Renaming orientation methods to get rid of the ambiguity
%rename(getQuaternion_RM) 
		getQuaternion(const Eigen::Matrix3d&);
%rename(getQuaternion_RPY) 
		getQuaternion(const Eigen::Vector3d&);
%rename(getInverseEulerAnglesRatesMatrix_RPY)
		getInverseEulerAnglesRatesMatrix(const Eigen::Vector3d&);
%rename(getInverseEulerAnglesRatesMatrix_RM)
		getInverseEulerAnglesRatesMatrix(const Eigen::Matrix3d&);
%rename(getInverseEulerAnglesRatesMatrix_Q)
		getInverseEulerAnglesRatesMatrix(const Eigen::Quaterniond&);
%rename(getEulerAnglesRatesMatrix_RPY)
		getEulerAnglesRatesMatrix(const Eigen::Vector3d&);
%rename(getEulerAnglesRatesMatrix_RM)
		getEulerAnglesRatesMatrix(const Eigen::Matrix3d&);
%rename(getEulerAnglesRatesMatrix_Q)
		getEulerAnglesRatesMatrix(const Eigen::Quaterniond&);


// Renaming few functions of the WholeBodyState class to get rid of the ambiguity
%rename(setContactPositionDict_W) setContactPosition_W(const rbd::BodyVectorXd&);
%rename(setContactPositionDict_B) setContactPosition_B(const rbd::BodyVectorXd&);
%rename(setContactPositionDict_H) setContactPosition_H(const rbd::BodyVectorXd&);
%rename(setContactVelocityDict_W) setContactVelocity_W(const rbd::BodyVectorXd&);
%rename(setContactVelocityDict_B) setContactVelocity_B(const rbd::BodyVectorXd&);
%rename(setContactVelocityDict_H) setContactVelocity_H(const rbd::BodyVectorXd&);
%rename(setContactAccelerationDict_W) setContactAcceleration_W(const rbd::BodyVectorXd&);
%rename(setContactAccelerationDict_B) setContactAcceleration_B(const rbd::BodyVectorXd&);
%rename(setContactAccelerationDict_H) setContactAcceleration_H(const rbd::BodyVectorXd&);
%rename(setContactWrenchDict_B) setContactWrench_B(const rbd::BodyVector6d&);


// Renaming few functions of the ReducedBodyState class to get rid of the ambiguity
%rename(setFootPositionDict_W) setFootPosition_W(const rbd::BodyVectorXd&);
%rename(setFootPositionDict_B) setFootPosition_B(const rbd::BodyVectorXd&);
%rename(setFootPositionDict_H) setFootPosition_H(const rbd::BodyVectorXd&);
%rename(setFootVelocityDict_W) setFootVelocity_W(const rbd::BodyVectorXd&);
%rename(setFootVelocityDict_B) setFootVelocity_B(const rbd::BodyVectorXd&);
%rename(setFootVelocityDict_H) setFootVelocity_H(const rbd::BodyVectorXd&);
%rename(setFootAccelerationDict_W) setFootAcceleration_W(const rbd::BodyVectorXd&);
%rename(setFootAccelerationDict_B) setFootAcceleration_B(const rbd::BodyVectorXd&);
%rename(setFootAccelerationDict_H) setFootAcceleration_H(const rbd::BodyVectorXd&);

// Ignoring two methods of the WholeBodyKinematic class that generate
// ambiguity
%ignore computeJointPosition(Eigen::VectorXd&,
							 const rbd::BodyVector3d&);
%ignore computeInverseKinematics(rbd::Vector6d&,
								 Eigen::VectorXd&,
								 const rbd::BodyVector3d&);


// Renaming some functions that generate ambiguity in the WholeBodyDynamic class
%rename(computeInverseDynamics_withoutFex)
		computeInverseDynamics(rbd::Vector6d&,
							   Eigen::VectorXd&,
							   const rbd::Vector6d&,
							   const Eigen::VectorXd&,
							   const rbd::Vector6d&,
							   const Eigen::VectorXd&,
							   const rbd::Vector6d&,
							   const Eigen::VectorXd&);
%rename(computeFloatingBaseInverseDynamics_withoutFex)
		computeFloatingBaseInverseDynamics(rbd::Vector6d&,
										   Eigen::VectorXd&,
										   const rbd::Vector6d&,
										   const Eigen::VectorXd&,
										   const rbd::Vector6d&,
										   const Eigen::VectorXd&,
										   const Eigen::VectorXd&);

%rename(urdf_Joint) urdf::Joint;
%rename(urdf_Pose) urdf::Pose;
%include <dwl/utils/RigidBodyDynamics.h>
%include <dwl/ReducedBodyState.h>
%include <dwl/WholeBodyState.h>
%include <urdf_model/pose.h>
%include <urdf_model/joint.h>
%include <dwl/utils/URDF.h>
%include <dwl/utils/Orientation.h>
%include <dwl/model/FloatingBaseSystem.h>
%include <dwl/model/WholeBodyKinematics.h>
%include <dwl/model/WholeBodyDynamics.h>
%include <dwl/RobotStates.h>

// Extending the C++ class by adding printing methods in python
%extend dwl::ReducedBodyState {
	char *__str__() {
		std::stringstream buffer;
		buffer << "ReducedBodyState:" << std::endl;
		buffer << "\ttime: " << $self->time << std::endl;
		buffer << "\tcom_pos: " << $self->getCoMPosition().transpose() << std::endl;
		buffer << "\tcom_vel: " << $self->getCoMVelocity_W().transpose() << std::endl;
		buffer << "\tcom_acc: " << $self->getCoMAcceleration_W().transpose() << std::endl;
		buffer << "\tangular_pos: " << $self->getRPY().transpose() << std::endl;
		buffer << "\tangular_vel: " << $self->getAngularVelocity_W().transpose() << std::endl;
		buffer << "\tangular_acc: " << $self->getAngularAcceleration_W().transpose() << std::endl;
		buffer << "\tcop: " << $self->getCoPPosition_W().transpose() << std::endl;
		buffer << "\tfoot_pos_B: " << std::endl;
		for (dwl::rbd::BodyVector3d::const_iterator it = $self->getFootPosition_B().begin();
				it != $self->getFootPosition_B().end(); ++it) {
			buffer << "\t\t" << it->first << ": " << it->second.transpose() << std::endl;
		}
		buffer << "\tfoot_vel_B: " << std::endl;
		for (dwl::rbd::BodyVector3d::const_iterator it = $self->getFootVelocity_B().begin();
				it != $self->getFootVelocity_B().end(); ++it) {
			buffer << "\t\t" << it->first << ": " << it->second.transpose() << std::endl;
		}
		buffer << "\tfoot_acc_B: " << std::endl;
		for (dwl::rbd::BodyVector3d::const_iterator it = $self->getFootAcceleration_B().begin();
				it != $self->getFootAcceleration_B().end(); ++it) {
			buffer << "\t\t" << it->first << ": " << it->second.transpose() << std::endl;
		}
		buffer << "	support_region: " << std::endl;
		for (dwl::rbd::BodyVector3d::const_iterator it = $self->support_region.begin();
				it != $self->support_region.end(); ++it) {
			buffer << "\t\t" << it->first << ": " << it->second.transpose() << std::endl;
		}
		std::string str = buffer.str();
		char * writable = new char[str.size() + 1];
		std::copy(str.begin(), str.end(), writable);
		writable[str.size()] = '\0';
		
		return writable;
	}
};

%extend dwl::WholeBodyState {
	char *__str__() {
		std::stringstream buffer;
		buffer << "WholeBodyState:" << std::endl;
		buffer << "\ttime: " << $self->time << std::endl;
		buffer << "\tbase_pos: " << $self->base_pos.transpose() << std::endl;
		buffer << "\tbase_vel: " << $self->base_vel.transpose() << std::endl;
		buffer << "\tbase_acc: " << $self->base_acc.transpose() << std::endl;
		buffer << "\tjoint_pos: " << $self->getJointPosition().transpose() << std::endl;
		buffer << "\tjoint_vel: " << $self->getJointVelocity().transpose() << std::endl;
		buffer << "\tjoint_acc: " << $self->getJointAcceleration().transpose() << std::endl;
		buffer << "\tjoint_eff: " << $self->getJointEffort().transpose() << std::endl;
		buffer << "\tcontact_pos_B: " << std::endl;
		for (dwl::rbd::BodyVectorXd::const_iterator it = $self->getContactPosition_B().begin();
				it != $self->getContactPosition_B().end(); ++it) {
			buffer << "\t\t" << it->first << ": " << it->second.transpose() << std::endl;
		}
		buffer << "\tcontact_vel_B: " << std::endl;
		for (dwl::rbd::BodyVectorXd::const_iterator it = $self->getContactVelocity_B().begin();
				it != $self->getContactVelocity_B().end(); ++it) {
			buffer << "\t\t" << it->first << ": " << it->second.transpose() << std::endl;
		}
		buffer << "\tcontact_acc_B: " << std::endl;
		for (dwl::rbd::BodyVectorXd::const_iterator it = $self->getContactAcceleration_B().begin();
				it != $self->getContactAcceleration_B().end(); ++it) {
			buffer << "\t\t" << it->first << ": " << it->second.transpose() << std::endl;
		}
		buffer << "\tcontact_eff_B: " << std::endl;
		for (dwl::rbd::BodyVector6d::const_iterator it = $self->getContactWrench_B().begin();
				it != $self->getContactWrench_B().end(); ++it) {
			buffer << "\t\t" << it->first << ": " << it->second.transpose() << std::endl;
		}
		std::string str = buffer.str();
		char * writable = new char[str.size() + 1];
		std::copy(str.begin(), str.end(), writable);
		writable[str.size()] = '\0';
		
		return writable;
	}
};




////////////////////////////////////////////////////////////////////////////////////
/////////////////////// Optimization-related core functions ////////////////////////
////////////////////////////////////////////////////////////////////////////////////
%feature("director") dwl::model::OptimizationModel;
%feature("director:except") {
	if( $error != NULL ) {
		PyObject *ptype, *pvalue, *ptraceback;
		PyErr_Fetch( &ptype, &pvalue, &ptraceback );
		PyErr_Restore( ptype, pvalue, ptraceback );
		PyErr_Print();
		Py_Exit(1);
	}
}

%include "numpy.i"
%init %{
	import_array();
%}
// For the typemap of the optimization model interface
%apply double& INOUT { double& cost };
%apply (double* IN_ARRAY1, int DIM1) {(double* decision, int decision_dim),
									  (const double* decision, int decision_dim),
									  (double* decision_lbound, int decision_dim1),
									  (double* decision_ubound, int decision_dim2),
									  (double* constraint_lbound, int constraint_dim1),
									  (double* constraint_ubound, int constraint_dim2),
									  (double* gradient, int grad_dim),
									  (double* constraint, int constraint_dim),
									  (double* jacobian_values, int nonzero_dim1),
									  (double* hessian_values, int nonzero_dim1),
									  (const double* lagrange, int constraint_dim)}
%apply (int* IN_ARRAY1, int DIM1) {(int* row_entries, int nonzero_dim2),
								   (int* col_entries, int nonzero_dim3)}
%typemap(directorin,numinputs=1) double &
{
	npy_intp dim = 1;
	$input = PyArray_SimpleNewFromData(1, &dim, NPY_DOUBLE, (void *)&$1);
}

%include <dwl/model/OptimizationModel.h>
%include <dwl/solver/OptimizationSolver.h>
%include <dwl/solver/IpoptNLP.h>
%include <dwl/solver/cmaesSOFamily.h>
%template(cmaesSO) dwl::solver::cmaesSOFamily<>;



////////////////////////////////////////////////////////////////////////////////////
////////////////////////////// Yaml parser functions ///////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
%apply bool &OUTPUT { bool& data };
%apply int &OUTPUT { int& data };
%apply double &OUTPUT { double& data };
%apply std::string &OUTPUT { std::string& data };
%apply std::vector<double> &OUTPUT { std::vector<double>& data };
%apply std::vector<std::string> &OUTPUT { std::vector<std::string>& data };
%ignore read(bool &,std::string const &);
%rename(readBool)
		read(bool& data,
			 const std::string&,
			 const YamlNamespace& ns);
%ignore read(int &,std::string const &);
%ignore read(int &,std::string const &,YAML::Node const &);
%rename(readInt)
		read(int& data,
			 const std::string& field,
			 const YamlNamespace& ns);
%ignore read(double &,std::string const &);
%ignore read(double &,std::string const &,YAML::Node const &);
%rename(readDouble)
		read(double& data,
			 const std::string& field,
			 const YamlNamespace& ns);
%ignore read(std::string &,std::string const &);
%ignore read(std::string &,std::string const &,YAML::Node const &);
%rename(readString)
		read(std::string& data,
			 const std::string& field,
			 const YamlNamespace& ns);
%ignore read(std::vector<double> &,std::string const &);
%ignore read(std::vector<double> &,std::string const &,YAML::Node const &);
%rename(readDoubleList)
		read(std::vector<double>& data,
			const std::string& field,
			const YamlNamespace& ns);
%ignore read(std::vector<std::string> &,std::string const &);
%ignore read(std::vector<std::string> &,std::string const &,YAML::Node const &);
%rename(readStringList)
		read(std::vector<std::string>& data,
			const std::string& field,
			const YamlNamespace& ns);
%ignore read(Eigen::Vector2d &,std::string const &);
%ignore read(Eigen::Vector2d &,std::string const &,YAML::Node const &);
%rename(readArray2d) read(Eigen::Vector2d& data,
				  const std::string& field,
				  const YamlNamespace& ns);
%ignore read(Eigen::Vector3d &,std::string const &);
%ignore read(Eigen::Vector3d &,std::string const &,YAML::Node const &);
%rename(readArray3d) read(Eigen::Vector3d& data,
				  const std::string& field,
				  const YamlNamespace& ns);
%ignore read(Eigen::Quaterniond &,std::string const &);
%ignore read(Eigen::Quaterniond &,std::string const &,YAML::Node const &);
%ignore read(Pose &,std::string const &);
%ignore read(Pose &,std::string const &,YAML::Node const &);
%ignore read(Pose &,std::string const &,YamlNamespace const &);
%ignore read(Pose3d &,std::string const &);
%ignore read(Pose3d &,std::string const &,YAML::Node const &);
%ignore read(Pose3d &,std::string const &,YamlNamespace const &);
%ignore read(Action3d &,std::string const &);
%ignore read(Action3d &,std::string const &,YAML::Node const &);
%ignore read(Action3d &,std::string const &,YamlNamespace const &);
%ignore read(SearchArea &,std::string const &);
%ignore read(SearchArea &,std::string const &,YAML::Node const &);
%ignore read(SearchArea &,std::string const &,YamlNamespace const &);
%ignore getNode(YAML::Node &,YamlNamespace const &);
%ignore operator<<(YAML::Emitter&,Eigen::Vector2d const &);
%ignore operator<<(YAML::Emitter&,Eigen::Vector3d const &);

%include <dwl/utils/YamlWrapper.h>