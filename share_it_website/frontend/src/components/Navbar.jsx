import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../AuthContext';

const Navbar = () => {
  const { user, logout } = useAuth();
  const [search, setSearch] = React.useState('');
  const navigate = useNavigate();

  const handleSearch = (e) => {
    if (e.key === 'Enter') {
      navigate(`/r/${search}`);
      setSearch('');
    }
  };



  return (
    <nav className="bg-white border-b border-gray-200 px-4 py-2 flex justify-between items-center sticky top-0 z-50">
      <div className="flex items-center space-x-4">
        <Link to="/" className="text-red-500 font-bold text-2xl">ShareIt</Link>
        <input
          type="text"
          placeholder="Search ShareIt"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          onKeyDown={handleSearch}
          className="bg-gray-100 border border-transparent rounded-full px-4 py-1.5 w-96 hover:bg-white hover:border-blue-500 focus:bg-white focus:border-blue-500 outline-none transition-all hidden md:block"
        />
      </div>
      <div className="flex items-center space-x-4">
        {user ? (
          <>
            <span className="text-gray-700 font-medium hidden sm:block">u/{user.username} ({user.karma})</span>
            <Link to="/create-post" className="bg-gray-200 hover:bg-gray-300 text-gray-900 px-4 py-1.5 rounded-full font-medium transition-colors">
              + Create
            </Link>
            <button
              onClick={logout}
              className="border border-red-500 text-red-500 hover:bg-red-50 px-4 py-1.5 rounded-full font-bold transition-colors"
            >
              Log Out
            </button>
          </>
        ) : (
          <>
            <Link
              to="/login"
              className="bg-red-500 hover:bg-red-600 text-white px-6 py-1.5 rounded-full font-bold transition-colors"
            >
              Log In
            </Link>
            <Link
              to="/register"
              className="border border-blue-500 text-blue-500 hover:bg-blue-50 px-6 py-1.5 rounded-full font-bold transition-colors"
            >
              Sign Up
            </Link>
          </>
        )}
      </div>
    </nav>
  );
};

export default Navbar;
